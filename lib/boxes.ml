type box = Immutable of string list list | Mutable of string array array
type render_type = Top | Middle | Bottom

let create_immutable_box b = Immutable b
let create_mutable_box b = Mutable b

type ctx = { acs : Curses.Acs.acs; mutable y : int }

let init () =
  let _ = Curses.initscr () in
  let acs = Curses.get_acs_codes () in
  { acs; y = 0 }

(** The subset of functions that both [Array.t]s & [List.t]s share that we need
    to use while rendering [box]es. *)
module type Iterable = sig
  type 'a t

  val length : 'a t -> int
  val iteri : (int -> 'a -> unit) -> 'a t -> unit
  val iter : ('a -> unit) -> 'a t -> unit
  val hd : 'a t -> 'a
end

let addch i : unit =
  let _ = Curses.refresh () in
  let b = Curses.addch i in
  if not b then failwith (Printf.sprintf "Failed to addch %d" i)

let addstr s : unit =
  let b = Curses.addstr s in
  if not b then failwith (Printf.sprintf "Failed to addstr %s" s)

module CursesBuffer = struct
  type el = Int of int | String of string
  type t = el list ref

  let create () : t = ref []
  let push (b : t) next = b := next :: !b

  let render b =
    (* Reverse since we've been pushing to the front *)
    let elements = List.rev !b in
    List.iter (function Int i -> addch i | String s -> addstr s) elements
end

let refresh () =
  let b = Curses.refresh () in
  if not b then failwith "Failed to refresh"

module Make (T : Iterable) = struct
  let newline c =
    c.y <- c.y + 1;
    (* move : y : int -> x : int -> bool *)
    let b = Curses.move c.y 0 in
    if not b then
      failwith (Printf.sprintf "Failed to move cursor to (%d, %d)" 0 c.y)
    else ()

  let render_bar first middle break last term_width widths =
    addch first;
    let widthsIdx = ref 0 in
    let widthsLength = Array.length widths in
    let nextBreakIdx = ref (Array.get widths 0) in
    for idx = 0 to term_width - 3 do
      let character =
        if idx = !nextBreakIdx then (
          widthsIdx := !widthsIdx + 1;
          if !widthsIdx < widthsLength then
            nextBreakIdx := !nextBreakIdx + 1 + Array.get widths !widthsIdx;
          break)
        else middle
      in
      addch character
    done;
    addch last

  let header c term_width widths =
    render_bar c.acs.ulcorner c.acs.hline c.acs.ttee c.acs.urcorner term_width
      widths

  let middle_header c term_width widths =
    render_bar c.acs.ltee c.acs.hline c.acs.plus c.acs.rtee term_width widths

  let footer c term_width widths =
    render_bar c.acs.llcorner c.acs.hline c.acs.btee c.acs.lrcorner term_width
      widths

  (** Render a [T] of strings. *)
  let render_row row widths render_t c =
    let open CursesBuffer in
    let term_width = ref 0 in
    let buffer = create () in
    T.iteri
      (fun i str ->
        let width = widths.(i) in
        push buffer (Int c.acs.vline);
        push buffer (String (Utils.right_pad str width));
        term_width := !term_width + width + 1)
      row;
    push buffer (Int c.acs.vline);
    term_width := !term_width + 1;
    (match render_t with
    | Top ->
        header c !term_width widths;
        newline c;
        render buffer
    | Middle ->
        middle_header c !term_width widths;
        newline c;
        render buffer
    | Bottom ->
        middle_header c !term_width widths;
        newline c;
        render buffer;
        newline c;
        footer c !term_width widths);
    newline c

  let render_box box c =
    let num_rows = T.length box in
    let first_row = T.hd box in
    (* TODO ensure all rows have the same number of cols *)
    let num_cols = T.length first_row in
    let max_widths =
      (fun max_widths ->
        T.iter
          (fun row ->
            T.iteri
              (fun i str ->
                let len = String.length str in
                if len > max_widths.(i) then max_widths.(i) <- len)
              row)
          box;
        max_widths)
        (Array.make num_cols 0)
    in
    T.iteri
      (fun idx row ->
        let last = num_rows - 1 in
        let render_t =
          match idx with 0 -> Top | _ when idx = last -> Bottom | _ -> Middle
        in
        render_row row max_widths render_t c)
      box;
    refresh ()
end

module MutableBoxes = Make (struct
  type 'a t = 'a Array.t

  let length = Array.length
  let iteri = Array.iteri
  let iter = Array.iter
  let hd a = Array.get a 0
end)

module ImmutableBoxes = Make (struct
  type 'a t = 'a List.t

  let length = List.length
  let iteri = List.iteri
  let iter = List.iter
  let hd = List.hd
end)

let render_box box acs_codes =
  match box with
  | Mutable a -> MutableBoxes.render_box a acs_codes
  | Immutable l -> ImmutableBoxes.render_box l acs_codes
