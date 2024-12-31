(lang dune 3.16)

(name box)

(generate_opam_files true)

(source
 (github christopherfujino/ocaml_box))

(authors "Christopher Fujino")

(maintainers "Christopher Fujino")

(license "BSD 3")

(documentation https://url/to/documentation)

(package
 (name box)
 (synopsis "A terminal user interface library.")
 (description "Render boxes to terminal.")
 (depends
   ocaml
   dune
   (curses (= 1.0.11)))
 (tags
  (ocaml tui ncurses)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/reference/dune-project/index.html
