# Same inputs, same factory

A whitepaper on why determinism and reproducibility matter in 2026, and what picasso's labs can do
for [ouroboric-dev](https://github.com/ouroboric-dev). Read the PDF,
[`WHITEPAPER.pdf`](../../../WHITEPAPER.pdf) at the repo root, or its text in
[`WHITEPAPER.md`](../../../WHITEPAPER.md).

| File | Is |
|---|---|
| `whitepaper.html` | the source; every reference in it was checked against Crossref, arXiv or the primary page |
| `render.mjs` | prints it to the PDF with headless Chromium (`node render.mjs`, Playwright on the module path) |
| `image.nix` | experiment B of §5.3: a factory-layer OCI image that `nix-build --check` rebuilds bit-for-bit |
| `zenodo.json`, `zenodo.py` | the Zenodo record for the paper alone (a report, CC BY 4.0), and the script that deposits it |
| `../../../WHITEPAPER.pdf` | the output, ten A4 pages, in the hosting plan's look; `WHITEPAPER.md` beside it is the same text as Markdown (`pandoc -t gfm` of the source, tidied) |

The ouroboric-dev material it quotes is CC BY 4.0 (© its authors), cited by repository and commit.
The Ouroboric name is a trademark of its project and is used only to identify it.

## Publishing on Zenodo

The paper gets its own Zenodo record and DOI, separate from picasso's software record in the root
`.zenodo.json`. Nothing here publishes: a published DOI can't be withdrawn, so the last step is a
person pressing Publish on zenodo.org.

```console
export ZENODO_TOKEN=...              # zenodo.org → Applications → Personal access token, scope deposit:write
python3 zenodo.py --self-test        # metadata and files, no network
python3 zenodo.py draft              # draft from zenodo.json, reserves the DOI into doi.txt
node render.mjs                      # the cover's "Cite as" line now shows the DOI
python3 zenodo.py upload             # attaches WHITEPAPER.pdf to the draft
```

Then review the draft on zenodo.org, publish it, and commit `doi.txt` with the re-rendered PDF.
`--sandbox` on `draft` rehearses the whole flow on sandbox.zenodo.org with a sandbox token.
