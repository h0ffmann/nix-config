#!/usr/bin/env python3
"""CI guard for the site's hard rules (AGENTS.md), run on the built page (`just build`): the
Marola and Ouroboric logos are always on it, loaded from their own repositories, Gabriel Volpe
stays credited with a link, and the header links the hosting plan."""
import pathlib
import re
import sys

SITE = pathlib.Path(__file__).resolve().parent
DIST = SITE / "dist"
errors = []
page = DIST / "index.html"
html = page.read_text() if page.exists() else ""
if not html:
    errors.append("dist/index.html is missing: run `just build` first")
for name, origin in [("marola", "https://raw.githubusercontent.com/marola-dev/marola/"),
                     ("ouroboric", "https://raw.githubusercontent.com/ouroboric-dev/ouroboric/")]:
    block = re.search(rf'<a\b[^>]*\bdata-logo="{name}"[^>]*>.*?</a>', html, re.S)
    if not block or not re.search(rf'<img\b[^>]*\bsrc="{re.escape(origin)}[^"]+\.svg"', block.group(0)):
        errors.append(f"the {name} logo is missing, or not loaded from {origin}")
if 'href="https://github.com/gvolpe/nix-config"' not in html:
    errors.append("the credit to Gabriel Volpe (gvolpe/nix-config) is missing")
if 'href="plan/hosting-plan.pdf"' not in html or not (DIST / "plan" / "hosting-plan.pdf").exists():
    errors.append("the hosting plan (plan/hosting-plan.pdf) is not linked or not published")
for copy in SITE.rglob("*"):
    if "build" in copy.relative_to(SITE).parts[:1]:
        continue
    if re.search(r"(marola|ouroboric).*logo|logo.*(marola|ouroboric)", copy.name, re.I):
        errors.append(f"{copy.relative_to(SITE)}: trademark logos are hotlinked, never copied here")
for e in errors:
    print(f"site/check.py: {e}", file=sys.stderr)
sys.exit(1 if errors else 0)
