let () =
  let open Box.Render in
  let _ = Box.Boxes.init () in
  (try
     (layout
        (Container { border = 1; child = Text "Yolo Dawg!" })
        { minWidth = 0; maxWidth = 100; minHeight = 0; maxHeight = 100 })
       .render
       0 0
   with exn ->
     Curses.endwin ();
     raise exn);
  let _ = Curses.getch () in
  Curses.endwin ()

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
