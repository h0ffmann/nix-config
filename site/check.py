#!/usr/bin/env python3
"""CI guard for the site's hard rules (AGENTS.md): the Marola and Ouroboric logos are always on
the page, loaded from their own repositories, and Gabriel Volpe stays credited with a link."""
import pathlib
import re
import sys

SITE = pathlib.Path(__file__).resolve().parent
html = (SITE / "index.html").read_text()
errors = []
for name, origin in [("marola", "https://raw.githubusercontent.com/marola-dev/marola/"),
                     ("ouroboric", "https://raw.githubusercontent.com/ouroboric-dev/ouroboric/")]:
    block = re.search(rf'<a class="logo" data-logo="{name}".*?</a>', html, re.S)
    if not block or not re.search(rf'<img[^>]+src="{re.escape(origin)}[^"]+\.svg"', block.group(0)):
        errors.append(f"the {name} logo is missing, or not loaded from {origin}")
if "https://github.com/gvolpe/nix-config" not in html:
    errors.append("the credit to Gabriel Volpe (gvolpe/nix-config) is missing")
for copy in SITE.rglob("*"):
    if re.search(r"(marola|ouroboric).*logo|logo.*(marola|ouroboric)", copy.name, re.I):
        errors.append(f"{copy.relative_to(SITE)}: trademark logos are hotlinked, never copied here")
for e in errors:
    print(f"site/check.py: {e}", file=sys.stderr)
sys.exit(1 if errors else 0)
