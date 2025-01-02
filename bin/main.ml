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
