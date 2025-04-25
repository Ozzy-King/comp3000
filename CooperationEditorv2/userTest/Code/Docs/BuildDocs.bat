@echo off
rem Build documentation for MultiTurn.
rem Output written in `build` directory.
rem Requires PanDoc and NodeJS (for Mermaid-CLI) to be installed.
rem http://pandoc.org/
rem http://nodejs.org/
rem http://github.com/mermaid-js/mermaid-cli
rem
rem 2022/11/06, Mind Feast Games
@echo on

:: Prepare build directory
mkdir build
copy /y *.png build

:: SVG for HTML
cmd /c npx -p @mermaid-js/mermaid-cli mmdc -i API.md -o build/API-svg.md
:: PNG for PDF
cmd /c npx -p @mermaid-js/mermaid-cli mmdc -i API.md --outputFormat=png -o build/API-png.md

cd build
pandoc --from markdown+emoji -V mainfont="DejaVu Sans" API-svg.md --highlight-style haddock -s --toc --html-q-tags -T MultiTurn -o API.html
pandoc --from markdown+emoji --pdf-engine=xelatex -V mainfont="DejaVu Sans" API-png.md --highlight-style haddock -s --toc -T MultiTurn -o API.pdf
cd ..
