# publisher

Markdown → LaTeX → PDF, reproducibly: **pandoc 3.7**, **TeX Live 2025** (`texliveMedium` plus
the packages the documents need; `xelatex` and `pdflatex`), **python + openai** (for
translation scripts that talk to any OpenAI-compatible endpoint), `just`, `poppler-utils`.
One locked nixpkgs, the same revision as `labs/pratico`.

```
just shell       # the toolchain on PATH, in your current directory
just versions    # pandoc / xelatex / pdflatex / openai versions
just smoke       # sample document through both engines, built in the Nix sandbox (CI runs this)
```

## Badges and emoji

Markdown that carries GitHub-style badges (`<img src="https://img.shields.io/badge/...">`,
optionally inside `<a href>`) renders to PDF with the badges re-typeset as colored pills, and
headings keep their emoji in color:

- `filters/shields-badges.lua` — pandoc Lua filter; every shields `<img>` becomes
  `\badge{label}{message}{HEX}` with the badge's own color, `\href`-wrapped when linked. Other
  `<img>` tags are dropped with a warning (pandoc's LaTeX writer never emits raw HTML). No-op
  for non-LaTeX output.
- `tex/publisher-badges.sty` — the `\badge` macro, a TikZ pill; `\usepackage{publisher-badges}`.
- Color emoji need **lualatex** and the fallback font: in the preamble,
  `\directlua{luaotfload.add_fallback("emojifb", {"Noto Color Emoji:mode=harf;"})}` then
  `\setmainfont{DejaVu Sans}[RawFeature={fallback=emojifb}]`.

- Japanese: `\usepackage{luatexja-fontspec}` then
  `\setmainjfont{HaranoAjiGothic-Regular.otf}[BoldFont=HaranoAjiGothic-Bold.otf]` — luatexja
  does CJK line breaking and punctuation; Harano Aji (Source Han derivative, luatexja's default)
  is in the TeX env as static OTFs. nixpkgs' Noto Sans CJK is a variable-font collection that
  luatexja cannot instantiate for bold or vertical faces, so it is not used. Flag emoji are
  regional-indicator pairs that luatexja would send to the Japanese font: add
  `\ltjdefcharrange{9}{"1F1E6-"1F1FF}` and `\ltjsetparameter{jacharrange={-9}}` (see
  `example/badges-preamble.tex`) so the emoji fallback draws them.

`mkPdf` and `just shell` export `PUBLISHER_FILTERS` (the filters directory), `TEXINPUTS`
(so the style is found) and `OSFONTDIR` (so luaotfload finds Noto Color Emoji); consumers
that call pandoc themselves can read the same three from `lib.<system>.env`.
`example/badges.md` + `example/check-filter.sh` are the check CI runs (`checks.filter`), and
`just smoke` also builds it with lualatex.

## Reusing it from another repository

The lab exports its toolchain and a `mkPdf` helper. A consumer keeps its own sources, template
and build script, and only borrows the environment:

```nix
{
  inputs.publisher.url = "github:h0ffmann/nix-config?dir=labs/publisher";
  outputs = { publisher, ... }:
    let systems = builtins.attrNames publisher.devShells; in {
      devShells = builtins.mapAttrs (_: shells: { default = shells.default; }) publisher.devShells;
      packages = nixpkgs.lib.genAttrs systems (system: {
        report = publisher.lib.${system}.mkPdf {
          name = "report";
          src = ./.;                                  # filter it to what the script reads
          command = "bash scripts/build_pdf.sh report"; # must write its PDFs into $OUT_DIR
        };
      });
    };
}
```

`mkPdf { name, src, command }` runs `command` inside `src` with the toolchain, `HOME` and
`TEXMFVAR` pointed at the build's temp dir, and copies every `*.pdf` from `$OUT_DIR` into the
output. The first consumer is [ww-lab](https://github.com/h0ffmann/ww-lab) (`flake.nix` there:
the course book and the UFRJ/DEL proposal).

`lib.${system}` also exposes `tex`, `python` and `tools` for shells that need only a part.

## GitHub Actions

`labs/publisher/action.yml` is a composite action that runs the consumer's flake in CI:
install Nix (with the magic cache), an optional `pre-build` script, `nix flake check`,
`nix build`, copy the PDFs to `pdf-dir`, upload them as an artifact, and optionally commit
them back. The caller needs `actions/checkout` first and `contents: write` when committing.

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    permissions: { contents: write }
    steps:
      - uses: actions/checkout@v4
        with: { fetch-depth: 0 }
      - uses: h0ffmann/nix-config/labs/publisher@main
        with:
          pre-build: nix develop . --command python3 -m unittest discover -s tests -v
          commit: ${{ github.ref == 'refs/heads/main' && github.event_name == 'push' }}
          commit-paths: pubs/proposal/pt
```

Inputs: `flake` (`.`), `pdf-dir` (`pdf`), `artifact-name` (`pubs-pdfs`, SHA appended),
`retention-days` (`30`), `install-nix` (`true`), `pre-build`, `commit` (`false`),
`commit-paths`, `commit-message`. It is not on the Marketplace (that needs a dedicated
repository with `action.yml` at the root); the subdirectory reference above is enough.

**Used by:** [ww-lab's `pubs.yml`](https://github.com/h0ffmann/ww-lab/blob/main/.github/workflows/pubs.yml)
— a complete, working caller: unit tests and a main-only translation step as `pre-build`,
`commit` on pushes to `main`, `commit-paths` for the generated translations. Its
[`flake.nix`](https://github.com/h0ffmann/ww-lab/blob/main/flake.nix) shows the `mkPdf` side.
