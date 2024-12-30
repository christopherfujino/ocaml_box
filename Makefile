PROJECT_NAME = box

.PHONY: run
run:
	OCAMLRUNPARAM=b dune exec $(PROJECT_NAME)

.PHONY: clean
clean:
	dune clean
