#!/usr/bin/env bash
# Smoke build: one paper with cross-references and a citation, through XeLaTeX (the PDF) and
# pdfLaTeX (what arXiv runs). Warnings fail the build, so an unresolved reference fails it.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
out="${OUT_DIR:-$here/build}"
mkdir -p "$out"
common=(-F pandoc-crossref --citeproc --bibliography "$here/refs.bib" --number-sections --fail-if-warnings)
for engine in xelatex pdflatex; do
  pandoc "$here/paper.md" "${common[@]}" --pdf-engine="$engine" -o "$out/paper-$engine.pdf"
  text="$(pdftotext "$out/paper-$engine.pdf" -)"
  for want in "Section 2" "Table 1" "Raymond" "10.5210/fm.v3i2.578"; do
    grep -qF "$want" <<<"$text" || { echo "paper-$engine.pdf: missing '$want'" >&2; exit 1; }
  done
done
echo "paper smoke: $out/paper-xelatex.pdf $out/paper-pdflatex.pdf"
