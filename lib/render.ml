module RenderBox = struct
  type t = {
    width : int;
    height : int;
    children : t list;
    render : int -> int -> unit;
  }

  let render r x y =
    List.iter (fun r -> r.render x y) r.children;
    r.render x y
end

module Constraints = struct
  type t = { minWidth : int; maxWidth : int; minHeight : int; maxHeight : int }
end

module Widget = struct
  type t = Text of string

  let render w x y =
    match w with Text s -> Printf.printf "Render text %s at %d, %d\n" s x y

  (* TODO pass a build context? *)
  let layout w (cons : Constraints.t) : RenderBox.t =
    match w with
    | Text s ->
        let width = String.length s in
        if width <= cons.maxWidth then
          { width; height = 1; children = []; render = render w }
        else failwith "TODO"
end
