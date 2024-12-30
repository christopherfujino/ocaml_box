PROJECT_NAME = box

.PHONY: run
run:
	OCAMLRUNPARAM=b dune exec $(PROJECT_NAME)

a.out: main.ml utils.cmx boxes.cmx
	ocamlopt -o a.out utils.cmx boxes.cmx main.ml

utils.cmx: utils.ml
	ocamlopt -o utils.native utils.ml

boxes.cmi: boxes.mli
	ocamlopt -o boxes.cmi boxes.mli

boxes.cmx: boxes.ml boxes.cmi utils.cmx
	ocamlopt -o boxes.native utils.cmx boxes.ml

.PHONY: clean
clean:
	rm -f a.out *.cmi *.cmx *.o *.native
