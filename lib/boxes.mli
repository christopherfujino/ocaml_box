(** The core rendering module for boxes. *)

(** An opaque type encapsulating boxes that can be rendered. *)
type box

type ctx

val init: unit -> ctx

(** Render a [box]. *)
val render_box: box -> ctx -> unit

val create_immutable_box: string list list -> box
val create_mutable_box: string array array -> box
