open Box

let () =
  let grid = Boxes.create_immutable_box
    [ [ "alpha"; "b"; "c"; "d" ]; [ "one"; "two"; "three"; "four" ] ]
  in
  print_string (Boxes.render_box grid)
