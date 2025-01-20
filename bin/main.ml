let () =
  let open Box.Render in
  let my_widget = Widget.Text "Yolo dawg" in
  let render_box = Widget.layout
    my_widget
    { minWidth = 0; maxWidth = 100; minHeight = 0; maxHeight = 100 } in
  RenderBox.render render_box 0 0;
  print_endline "end"

(*
open Box.Boxes

let () =
  let open Curses in
  let c = init () in
  let grid =
    create_mutable_box
      [| [| "1"; "2"; "3" |]; [| "alpha"; "beta"; "delta" |] |]
  in
  (try render_box grid c
   with exn ->
     endwin ();
     raise exn);

  let i = getch () in
  endwin ();
  let c = Char.chr i in
  Printf.printf "You pressed %c\n" c
  *)
