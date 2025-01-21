let debug = false

let mvaddstr y x s =
  let result = Curses.mvaddstr y x s in
  (* TODO optimize? *)
  (if debug then
     let _ = Curses.refresh () in
     Unix.sleep 1);
  if not result then
    failwith (Printf.sprintf "Curses.mvaddstr %d %d \"%s\" failed" y x s)
  else ()

type size = { width : int; height : int }
type widget = Text of string | Container of { border : int; child : widget }

module RenderBox = struct
  type t = { width : int; height : int; render : int -> int -> unit }

  (* TODO use this? *)
  let render x y r = r.render x y
end

module Constraints = struct
  type t = { minWidth : int; maxWidth : int; minHeight : int; maxHeight : int }
end

module Widget = struct
  let rec render w x y =
    match w with
    | Container { border; child } ->
        let border = border in
        mvaddstr y x (String.make 5 '*');
        render child (x + border) (y + border)
        (* Actually render border *)
    | Text s -> mvaddstr y x s

  (* TODO pass a build context? *)
  let rec layout w (cons : Constraints.t) : RenderBox.t =
    match w with
    | Container { border; child } ->
        let border_width = border in
        (* TODO check for underflow *)
        let child_box =
          layout child
            {
              cons with
              maxWidth = cons.maxWidth - (border_width * 2);
              maxHeight = cons.maxHeight - (border_width * 2);
            }
        in
        {
          width = child_box.width + (border_width * 2);
          height = child_box.height + (border_width * 2);
          render = render w;
        }
    | Text s ->
        let width = String.length s in
        if width <= cons.maxWidth then { width; height = 1; render = render w }
        else failwith "TODO"
end
