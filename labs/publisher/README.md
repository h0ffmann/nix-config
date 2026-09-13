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
