#!/bin/bash


echo "Running R script..."
Rscript miniproject_code.R


echo "Compiling LaTeX document..."
pdflatex -shell-escape -output-directory=../results miniproject.tex

echo "Running BibTeX..."
bibtex miniproject

echo "Compiling LaTeX again to update references..."
pdflatex -shell-escape -output-directory=../results miniproject.tex


echo "Final LaTeX compilation..."
pdflatex -shell-escape -output-directory=../results miniproject.tex


echo "Opening the PDF..."
evince ../results/miniproject_final.pdf

echo "Cleaning up temporary files..."
rm -f *.aux *.log *.bbl *.blg *.toc *.lof *.lot *.out *.fls *.synctex.gz *.xdv *.fdb_latexmk *.nav *.snm 


echo "Process completed!"
