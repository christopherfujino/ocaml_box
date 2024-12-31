type box = Immutable of string list list | Mutable of string array array
type render_type = Top | Middle | Bottom

let topRightCorner = "\u{2510}"
let topLeftCorner = "\u{250c}"
let bottomLeftCorner = "\u{2514}"
let bottomRightCorner = "\u{2518}"
let horizontalBar = "\u{2500}"
let verticalBar = "\u{2502}"
let midRightBar = "\u{251c}" (* ├ *)
let midLeftBar = "\u{2524}" (* ┤ *)
let topMiddleBar = "\u{252c}" (* ┬ *)
let bottomMiddleBar = "\u{2534}" (* ┴ *)
let cross = "\u{253c}" (* ┼ *)
let create_immutable_box b = Immutable b
let create_mutable_box b = Mutable b

(** The subset of functions that both [Array.t]s & [List.t]s share that we need
    to use while rendering [box]es. *)
module type Iterable = sig
  type 'a t

  val length : 'a t -> int
  val iteri : (int -> 'a -> unit) -> 'a t -> unit
  val iter : ('a -> unit) -> 'a t -> unit
  val hd : 'a t -> 'a
end

module Make (T : Iterable) = struct
  let render_bar first middle break last term_width widths =
    let buffer = Buffer.create term_width in
    let write = Buffer.add_string buffer in
    write first;
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
      write character
    done;
    write last;
    Buffer.contents buffer

  (** Render a [T] of strings *)
  let render_row row widths render_t =
    let middle_buffer = Buffer.create 32 in
    let term_width = ref 0 in
    T.iteri
      (fun i str ->
        let width = widths.(i) in
        let formatted_str = Utils.right_pad str width in
        Buffer.add_string middle_buffer verticalBar;
        Buffer.add_string middle_buffer formatted_str;
        term_width := !term_width + width + 1)
      row;
    Buffer.add_string middle_buffer verticalBar;
    term_width := !term_width + 1;
    let header () =
      render_bar topLeftCorner horizontalBar topMiddleBar topRightCorner
        !term_width widths
    in
    let middle_header () =
      render_bar midRightBar horizontalBar cross midLeftBar !term_width widths
    in
    let footer () =
      render_bar bottomLeftCorner horizontalBar bottomMiddleBar
        bottomRightCorner !term_width widths
    in
    let middle_contents = Buffer.contents middle_buffer in
    match render_t with
    | Top -> header () ^ "\n" ^ middle_contents ^ "\n"
    | Middle -> middle_header () ^ "\n" ^ middle_contents ^ "\n"
    | Bottom ->
        middle_header () ^ "\n" ^ middle_contents ^ "\n" ^ footer () ^ "\n"

  let render_box box =
    let num_rows = T.length box in
    let first_row = T.hd box in
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
    let buffer = Buffer.create 100 in
    let write = Buffer.add_string buffer in
    T.iteri
      (fun idx row ->
        let last = num_rows - 1 in
        let render_t =
          match idx with 0 -> Top | _ when idx = last -> Bottom | _ -> Middle
        in
        write (render_row row max_widths render_t))
      box;
    Buffer.contents buffer
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

let render_box = function
  | Mutable a -> MutableBoxes.render_box a
  | Immutable l -> ImmutableBoxes.render_box l
