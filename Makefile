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

.PHONY: build
build:
	dune build

.PHONY: clean
clean:
	dune clean

.PHONY: get
get:
	opam install . --deps-only --with-test --with-doc -vv
