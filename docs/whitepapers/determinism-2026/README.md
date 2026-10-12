# Same inputs, same factory

A whitepaper on why determinism and reproducibility matter in 2026, and what picasso's labs can do
for [ouroboric-dev](https://github.com/ouroboric-dev). Read the PDF:
[`determinism-2026.pdf`](determinism-2026.pdf).

| File | Is |
|---|---|
| `whitepaper.html` | the source; every reference in it was checked against Crossref, arXiv or the primary page |
| `render.mjs` | prints it to the PDF with headless Chromium (`node render.mjs`, Playwright on the module path) |
| `image.nix` | experiment B of §5.3: a factory-layer OCI image that `nix-build --check` rebuilds bit-for-bit |
| `determinism-2026.pdf` | the output, ten A4 pages, in the hosting plan's look |

The ouroboric-dev material it quotes is CC BY 4.0 (© its authors), cited by repository and commit.
The Ouroboric name is a trademark of its project and is used only to identify it.
