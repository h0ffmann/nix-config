#!/usr/bin/env bash
# Filter check: badges.md through the shields filter to LaTeX, then the exact macros expected.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
filters="${PUBLISHER_FILTERS:-$here/../filters}"
out="${OUT_DIR:-$here/build}"
mkdir -p "$out"
pandoc "$here/badges.md" --from markdown+raw_html --to latex --lua-filter "$filters/shields-badges.lua" -o "$out/badges.tex"
expect() { grep -qF -- "$1" "$out/badges.tex" || { echo "check-filter: missing: $1" >&2; cat "$out/badges.tex" >&2; exit 1; }; }
expect '\badge{}{Scala}{DC322F}'
expect '\badge{AWS}{ML Specialty}{FF9900}'
expect '\href{https://github.com/topics/civic-tech}{\badge{}{civic-tech}{0077BE}}'
expect '\badge{}{Hugging Face}{FFD21E}'
expect '\badge{build}{passing}{44CC11}'
expect '\href{https://marola.dev}{\badge{}{🌊 marola.dev}{0077BE}}'
expect '\badge{PADI}{Rescue Diver}{0B5FA5}'
expect 'Texto normal com \textbf{negrito} continua igual.'
expect '{\raggedright \badge{}{Scala}{DC322F}'
if grep -q 'not-a-badge' "$out/badges.tex"; then echo "check-filter: non-shields image leaked into LaTeX" >&2; exit 1; fi
echo "check-filter: ok"
