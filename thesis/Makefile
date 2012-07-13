PDFLATEX = /usr/texbin/pdflatex
BIBTEX = /usr/texbin/bibtex


TEXFILES = $(wildcard *.tex)

thesis.pdf: $(TEXFILES)
	$(PDFLATEX) thesis.tex && $(BIBTEX) thesis && $(PDFLATEX) thesis.tex && $(PDFLATEX) thesis.tex && open thesis.pdf



clean:
	rm -f thesis.pdf *.aux thesis.toc thesis.log thesis.out thesis.bbl thesis.blg thesis *.log *.synctex.gz *.log *.fdb_latexmk
