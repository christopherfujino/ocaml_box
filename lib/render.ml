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

type widget = Text of string | Container of { border : int; child : widget }

type constraints = {
  minWidth : int;
  maxWidth : int;
  minHeight : int;
  maxHeight : int;
}

type size = { height : int; width : int }

type render_target = {
  size : size;
  children : render_target list;
  render : int -> int -> unit;
}

(* TODO pass a build context? *)
let rec layout w (cons : constraints) =
  match w with
  | Container { border; child } ->
      (* TODO check for underflow *)
      let child_target =
        layout child
          {
            cons with
            maxWidth = cons.maxWidth - (border * 2);
            maxHeight = cons.maxHeight - (border * 2);
          }
      in
      {
        size =
          {
            width = child_target.size.width + (border * 2);
            height = child_target.size.height + (border * 2);
          };
        children = [ child_target ];
        render =
          (fun x y ->
            let border = border in
            mvaddstr y x (String.make 5 '*');
            child_target.render (x + border) (y + border));
      }
  | Text s ->
      let width = String.length s in
      if width <= cons.maxWidth then
        {
          size = { width; height = 1 };
          children = [];
          render = (fun x y -> mvaddstr y x s);
        }
      else failwith "TODO"
