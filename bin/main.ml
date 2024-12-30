open Box

let () =
  let grid =
    Boxes.create_immutable_box
      [ [ "alpha"; "b"; "c"; "d" ]; [ "one"; "two"; "three"; "four" ] ]
  in
  print_string (Boxes.render_box grid)

let () =
  let grid =
    Boxes.create_mutable_box
      [| [| "1"; "two"; "delta"; "the fourth entry" |]; [| "lala" |] |]
  in
  print_string (Boxes.render_box grid)
