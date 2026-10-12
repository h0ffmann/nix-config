#!/usr/bin/env bash
# Smoke build: compile with gleam, run the result on node, bundle it with esbuild, and check
# that both print the page.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
out="${OUT_DIR:-$here/dist}"
mkdir -p "$out"
cd "$here"
gleam build --no-print-progress
gleam run --no-print-progress > "$out/index.html"
esbuild entry.mjs --bundle --minify --format=esm --outfile="$out/app.js" --log-level=warning
node "$out/app.js" | cmp - "$out/index.html"
grep -qF '<h1>gleam-website smoke</h1>' "$out/index.html" || { echo "smoke: page missing" >&2; exit 1; }
echo "gleam-website smoke: $out/index.html $out/app.js"
