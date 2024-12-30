let right_pad str width =
  let len = String.length str in
  if len > width then failwith "string overflow in right_pad";
    String.init width (fun idx -> if idx < len then String.get str idx else ' ')
