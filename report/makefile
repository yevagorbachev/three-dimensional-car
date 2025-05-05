all:
	# latexmk -pdf -shell-escape -halt-on-error car_model.tex
	latexmk -pdf -shell-escape -halt-on-error -xelatex car_model.tex
clean:
	latexmk -c
	rm -f *eps-converted-to.pdf
	rm -f **/*eps-converted-to.pdf
