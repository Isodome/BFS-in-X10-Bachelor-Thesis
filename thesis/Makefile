PDFLATEX = /usr/texbin/pdflatex
BIBTEX = /usr/texbin/bibtex


TEXFILES = $(wildcard *.tex)

thesis.pdf: $(TEXFILES)
	$(PDFLATEX) thesis.tex

clean:
	rm -f thesis.pdf thesis.aux thesis.bib	thesis.toc thesis.log thesis.out