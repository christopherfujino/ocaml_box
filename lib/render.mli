type constraints = {
  minWidth : int;
  maxWidth : int;
  minHeight : int;
  maxHeight : int;
}

type widget = Text of string | Container of { border : int; child : widget }
type size
type render_target = {
  size : size;
  children : render_target list;
  render : int -> int -> unit;
}


val layout : widget -> constraints -> render_target
