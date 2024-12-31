(** The core rendering module for boxes. *)

(** An opaque type encapsulating boxes that can be rendered. *)
type box

(** Take a box and return a string representation that can be printed. *)
val render_box: box -> string

val create_immutable_box: string list list -> box
val create_mutable_box: string array array -> box
