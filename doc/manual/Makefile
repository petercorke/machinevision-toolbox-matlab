vision.pdf: titlepage.pdf vision.tex all.tex
	printf '\\def\\release{%s}\n' `cat ../../../RELEASE` > release.tex
	printf '\\def\\reldate{%s}\n' "`date '+%B %Y'`" >> release.tex
	pdflatex vision
	sh funcidx_make.sh
	pdflatex vision

titlepage.pdf: figs/mvtb-montage.png
	convert $< $@

clean:
	-rm titlepage.pdf *.idx *.ind *.ilg *.aux *.log *.out *.toc
