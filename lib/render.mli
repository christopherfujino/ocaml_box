type constraints = {
  minWidth : int;
  maxWidth : int;
  minHeight : int;
  maxHeight : int;
}

type widget = Text of string | Container of { border : int; child : widget }
type size
type render_target
val layout : widget -> constraints -> render_target
val render : int -> int -> render_target -> unit
