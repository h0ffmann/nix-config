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
# lualatex: shields badges → TikZ pills through the filter, color emoji through the fallback font,
# Japanese through luatexja. Two explicit steps (pandoc → .tex, lualatex → .pdf) so a TeX failure
# shows its own log here instead of pandoc's one-line summary.
pandoc "$here/badges.md" --from markdown+raw_html --to latex --standalone --fail-if-warnings \
  --lua-filter "${PUBLISHER_FILTERS:-$here/../filters}/shields-badges.lua" -H "$here/badges-preamble.tex" \
  -o "$out/badges-lualatex.tex"
if ! (cd "$out" && lualatex -interaction=nonstopmode -halt-on-error badges-lualatex.tex > badges-lualatex.stdout 2>&1); then
  echo "badges-lualatex.tex: lualatex failed; log tail:" >&2
  tail -n 60 "$out/badges-lualatex.log" >&2
  exit 1
fi
if grep -q 'Missing character' "$out/badges-lualatex.log"; then
  echo "badges-lualatex.pdf: glyphs missing (a font lacks a character that should have a fallback):" >&2
  grep 'Missing character' "$out/badges-lualatex.log" | sort -u | head >&2
  exit 1
fi
rm -f "$out"/badges-lualatex.{aux,out,stdout}
# luaotfload embeds color emoji as bitmap images (one image + soft mask each); badges.md has three
emoji="$(pdfimages -list "$out/badges-lualatex.pdf" | awk 'NR>2 && $3=="image"' | wc -l)"
[ "$emoji" -ge 4 ] || { echo "badges-lualatex.pdf: expected 4 color emoji bitmaps, found $emoji" >&2; exit 1; }
# Japanese text must survive as text (luatexja + Harano Aji Gothic), not tofu
pdftotext "$out/badges-lualatex.pdf" - | grep -q '決済処理と不正対策' || { echo "badges-lualatex.pdf: Japanese text missing" >&2; exit 1; }
pdffonts "$out/badges-lualatex.pdf" | grep -q 'HaranoAjiGothic' || { echo "badges-lualatex.pdf: Harano Aji Gothic not embedded" >&2; exit 1; }
echo "publisher smoke: $out/smoke-xelatex.pdf $out/smoke-pdflatex.pdf $out/badges-lualatex.pdf"
