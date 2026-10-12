#!/usr/bin/env bash
# Smoke build for the optional docx output: the same sample through pandoc's docx writer.
# No TeX is involved — docx is what a consumer asks for when someone wants to edit or comment
# the document in Word or Google Docs instead of reading a PDF.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
out="${OUT_DIR:-$here/build}"
mkdir -p "$out"

pandoc "$here/smoke.md" --citeproc --bibliography "$here/refs.bib" --fail-if-warnings \
  -o "$out/smoke.docx"

# A .docx is a zip of XML parts. Prove the writer produced a real document part and that the
# sample's text and its citation survived, so a broken pandoc build fails here and not in a
# consumer's release.
python3 - "$out/smoke.docx" <<'PY'
import sys
import zipfile

with zipfile.ZipFile(sys.argv[1]) as z:
    names = z.namelist()
    assert "word/document.xml" in names, names[:10]
    xml = z.read("word/document.xml").decode("utf-8")
for expected in ("hifenização", "WAVEWATCH"):
    assert expected in xml, f"{expected!r} missing from word/document.xml"
print(f"docx ok: {len(names)} parts")
PY
echo "publisher docx smoke: $out/smoke.docx"
