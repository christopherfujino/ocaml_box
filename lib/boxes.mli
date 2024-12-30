type box

val render_box: box -> string

val create_immutable_box: string list list -> box
val create_mutable_box: string array array -> box
