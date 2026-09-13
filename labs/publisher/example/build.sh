#!/usr/bin/env bash
# Smoke build: the same sample through both engines this lab supports.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
out="${OUT_DIR:-$here/build}"
mkdir -p "$out"
common=(--citeproc --bibliography "$here/refs.bib" --fail-if-warnings)
# xelatex: unicode symbols via DejaVu Sans loaded by filename (no fontconfig in the sandbox)
pandoc "$here/smoke.md" "${common[@]}" --pdf-engine=xelatex \
  -V mainfont=DejaVuSans -V mainfontoptions="Extension=.ttf" -V monofont=DejaVuSansMono -V monofontoptions="Extension=.ttf" \
  -o "$out/smoke-xelatex.pdf"
# pdflatex: T1/utf8 path (the UFRJ proposal template); strip the symbols it cannot encode
sed 's/⚠ ✔ → ≥/(simbolos omitidos em pdflatex)/' "$here/smoke.md" > "$out/smoke-pdflatex.md"
pandoc "$out/smoke-pdflatex.md" "${common[@]}" --pdf-engine=pdflatex -o "$out/smoke-pdflatex.pdf"
rm -f "$out/smoke-pdflatex.md"
echo "publisher smoke: $out/smoke-xelatex.pdf $out/smoke-pdflatex.pdf"
