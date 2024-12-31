PROJECT_NAME = box

.PHONY: run
run:
	OCAMLRUNPARAM=b dune exec $(PROJECT_NAME)

.PHONY: doc
doc: generate-docs
	xdg-open _build/default/_doc/_html/index.html

.PHONY: generate-docs
generate-docs:
	dune build @doc
#	dune build @doc-private

.PHONY: clean
clean:
	dune clean
