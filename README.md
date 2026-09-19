<div align="center">

<img alt="Nix" src="https://raw.githubusercontent.com/NixOS/nixos-artwork/9d2cdedd73d64a068214482902adea3d02783ba8/logo/nix-snowflake-rainbow.svg" width="140px"/>

# :ocean: nix-config :ocean:

[![ci-badge](https://img.shields.io/static/v1?label=Built%20with&message=nix&color=blue&style=flat&logo=nixos&link=https://nixos.org&labelColor=111212)](https://nixos.org)
[![ci](https://github.com/h0ffmann/nix-config/actions/workflows/ci.yml/badge.svg)](https://github.com/h0ffmann/nix-config/actions/workflows/ci.yml)

My [Nix](https://nixos.org/) labs: self-contained flakes for the tools I actually work in, on an
Ubuntu workstation (i9 + RTX 4090) running [Determinate Nix](https://determinate.systems/nix/).
Each lab is one directory with its own `flake.nix`, `flake.lock`, `justfile` and README, references
nothing outside itself, and works unchanged as a git submodule of the repositories that consume it.
</div>

## prático

The WAVEWATCH III toolchain that [ww-lab](https://github.com/h0ffmann/ww-lab) builds in, plus a local
zsh pilot and a sandbox for coding agents. See [`labs/pratico`](labs/pratico).

```console
cd labs/pratico
just ww3              # toolchain-only shell — gfortran, OpenMPI, NetCDF, METIS, ecCodes, python
just toolchain        # exact pinned versions, for a paper's methods section
just smoke            # Fortran 2008 + MPI + NetCDF-4 compiled and run in the sandbox (CI)
just kokkos-smoke     # Kokkos + GoogleTest compiled, tested and run in the sandbox (CI)
just cuda             # toolchain shell with Kokkos built for CUDA — x86_64-linux, needs a GPU
just dev              # interactive shell: same toolchain + zsh-ai (Ctrl+O) → llm → Ollama
just jco              # Claude Code inside ai-jail (jcf / jcs for other models, jo for OpenCode)
```

<details>
<summary>Environment details</summary>

| Type              | Program |
| :---------------- | :-----: |
| Fortran / C / C++ | [GCC 15](https://gcc.gnu.org/) (`gfortran`) |
| MPI               | [OpenMPI 5](https://www.open-mpi.org/) |
| NetCDF            | [netcdf-c 4.10](https://www.unidata.ucar.edu/software/netcdf/) + netcdf-fortran, HDF5 |
| Decomposition     | [METIS](https://github.com/KarypisLab/METIS) / ParMETIS |
| GRIB              | [ecCodes](https://confluence.ecmwf.int/display/ECC) |
| C++ portability   | [Kokkos](https://kokkos.org/) (Serial + OpenMP, CUDA in `just cuda`) + [GoogleTest](https://google.github.io/googletest/), gdb, valgrind |
| Build             | [CMake](https://cmake.org/) / Ninja |
| Analysis          | [nco](https://nco.sourceforge.net/), [cdo](https://code.mpimet.mpg.de/projects/cdo), python (numpy, scipy, xarray, netCDF4, matplotlib) |
| Shell pilot       | [zsh-ai](https://github.com/thiswillbeyourgithub/zsh-ai) → [llm](https://llm.datasette.io/) → [Ollama](https://ollama.com/) (`qwen2.5-coder:7b`) |
| Agent sandbox     | [ai-jail](https://github.com/akitaonrails/ai-jail) (bubblewrap / Landlock / seccomp) |
| Task runner       | [just](https://github.com/casey/just) |

</details>

## publisher

Markdown → LaTeX → PDF, reproducibly, and `mkPdf` / `mkDocx` helpers so other repositories build
their documents in the Nix sandbox with this toolchain. docx is optional and takes the pandoc
writer, no TeX. First consumer: ww-lab's course book and its UFRJ/DEL project proposal.
See [`labs/publisher`](labs/publisher).

```console
cd labs/publisher
just shell            # pandoc, xelatex / pdflatex, python + openai on PATH
just versions         # what is pinned
just smoke            # sample document through both engines, built in the sandbox (CI)
just smoke-docx       # the same sample as .docx, the optional non-TeX output (CI)
```

<details>
<summary>Environment details</summary>

| Type            | Program |
| :-------------- | :-----: |
| Converter       | [pandoc 3.7](https://pandoc.org/) (citeproc, Lua filters) |
| TeX             | [TeX Live 2025](https://tug.org/texlive/) `texliveMedium` + babel-portuges, fontspec, DejaVu, fvextra, titlesec, … |
| Engines         | `xelatex` (books, unicode fonts by filename) and `pdflatex` (T1 templates) |
| Scripting       | python 3 + [openai](https://github.com/openai/openai-python) (translation against any OpenAI-compatible endpoint) |
| PDF tools       | [poppler-utils](https://poppler.freedesktop.org/) (`pdfinfo`, `pdftotext`, `pdftoppm`), [librsvg](https://gitlab.gnome.org/GNOME/librsvg) (`rsvg-convert`, SVG images in PDFs) |
| Badges & emoji  | `filters/shields-badges.lua` → `publisher-badges.sty` (shields.io badges as TikZ pills), [Noto Color Emoji](https://github.com/googlefonts/noto-emoji) via luaotfload fallback (`lualatex`) |
| Japanese        | [luatexja](https://ctan.org/pkg/luatexja) + [Harano Aji](https://github.com/trueroad/HaranoAjiFonts) Gothic/Mincho (`lualatex`) |
| Reuse           | `lib.<system>.{mkPdf, mkDocx, mkDocument}` and the composite GitHub Action `h0ffmann/nix-config/labs/publisher@main` |
| docx (optional) | pandoc's docx writer — no TeX, no LaTeX template, styling from a consumer's `--reference-doc` |

</details>

## lint

The gate a repository runs before a PR — hadolint, actionlint + shellcheck, ruff, pyflakes,
cloc, coverage.py, pdoc — exported as one list for a consumer's `mkShell`. See
[`labs/lint`](labs/lint).

```console
cd labs/lint
just shell            # the tools on PATH
just versions         # what is pinned, built in the sandbox (CI)
```

<details>
<summary>Environment details</summary>

| Type       | Program |
| :--------- | :-----: |
| Dockerfile | [hadolint](https://github.com/hadolint/hadolint) |
| Workflows  | [actionlint](https://github.com/rhysd/actionlint) + [shellcheck](https://www.shellcheck.net/) for the `run:` blocks |
| Python     | [ruff](https://docs.astral.sh/ruff/), [pyflakes](https://github.com/PyCQA/pyflakes), [coverage.py](https://coverage.readthedocs.io/), [pdoc](https://pdoc.dev/) |
| Counting   | [cloc](https://github.com/AlDanial/cloc) |
| Reuse      | `lib.<system>.tools` (the list), `packages.<system>.<tool>`, `checks.<system>.versions` |

</details>

## agentic

The sandbox for coding agents and the host-side scripts around it: **ai-jail** (bubblewrap /
Landlock / seccomp), **OpenCode**, **Open Code Review** (`ocr`, built from source), **gh**, and
`jail-run` / `gh-token` / `clip` / `clip-relay` — one file each, with a `--self-test` that
`nix flake check` runs in the sandbox. See [`labs/agentic`](labs/agentic).

```console
cd labs/agentic
just self-test        # every script's --self-test, from source
just jco              # Claude Code inside ai-jail, in YOUR directory (jcf / jcs for other models, jo for OpenCode)
just jocr             # Open Code Review inside ai-jail: project read-only, no GitHub token
just jail-dry-run ls  # what ai-jail would run
```

<details>
<summary>Environment details</summary>

| Type          | Program |
| :------------ | :-----: |
| Agent sandbox | [ai-jail](https://github.com/akitaonrails/ai-jail) (bubblewrap / Landlock / seccomp, Linux) |
| Agents        | Claude Code (the consumer's own), [OpenCode](https://opencode.ai/) |
| Reviewer      | [Open Code Review](https://github.com/alibaba/open-code-review) v1.12.7, `buildGoModule` from the tag — `jail-run ocr` gives it no token and a read-only project |
| GitHub        | [gh](https://cli.github.com/); `gh-token` resolves the token on the host, `jail-run` forwards it as `GH_TOKEN` |
| Clipboard     | `clip` (write-only, from inside the jail) → `clip-relay` → wl-copy / xclip |
| Reuse         | `lib.<system>.{tools, env, scripts}`, `packages.<system>.{<script>, ocr}`, `checks.<system>.{gh-token, jail-run}` |

</details>

## cuda

Host setup for a CUDA box, x86_64-linux only: `setup-cuda-cache` puts the nixos-cuda binary
cache into Determinate Nix's `nix.custom.conf` (replacing the dead Cachix block that 401s), and
`REQUIREMENTS=<file> setup-ml-venv` builds a torch venv from PyTorch's wheel index with the nix
libstdc++ and the NVIDIA driver libraries on its path. See [`labs/cuda`](labs/cuda).

```console
cd labs/cuda
just self-test                       # both --self-tests, from source
just cache-setup                     # the nix.custom.conf block, dry-run; `sudo just cache-setup apply` writes it
just venv path/to/requirements.txt   # the venv; call bin/python-cuda afterwards
```

<details>
<summary>Environment details</summary>

| Type         | Program |
| :----------- | :-----: |
| Binary cache | [cache.nixos-cuda.org](https://cache.nixos-cuda.org) via `extra-substituters` + `trusted-users` |
| torch        | PyTorch's CUDA wheel index (`CUDA_INDEX`, default cu129), never nixpkgs' `torchWithCuda` |
| Wrapper      | `$VENV_ROOT/bin/python-cuda` — nix libstdc++ baked in at build, driver libs linked at run |
| Reuse        | `lib.x86_64-linux.tools`, `packages.x86_64-linux.{setup-cuda-cache,setup-ml-venv}`, `checks.x86_64-linux.*` |

</details>

## Structure

```
.
├── labs/
│   ├── pratico/        WW3 toolchain, zsh-ai pilot, ai-jail       (flake, lock, justfile, README, scripts/)
│   ├── publisher/      pandoc + TeX Live, mkPdf, action.yml       (flake, lock, justfile, README, example/)
│   ├── lint/           lint toolchain as one list, checks.versions   (flake, lock, justfile, README)
│   ├── agentic/        ai-jail, OpenCode, ocr, gh, jail-run/gh-token/clip  (flake, lock, justfile, README, scripts/)
│   └── cuda/           CUDA binary cache + torch venv, x86_64 only   (flake, lock, justfile, README, scripts/)
├── notes/              things worth writing down once (legacy NixOS root, …)
├── .github/workflows/  ci.yml: root evaluates, every lab is built and linted
└── flake.nix, configuration.nix, home.nix, …   legacy NixOS system configuration (see notes/)
```

Every lab also carries a `lab.json` — a one-line summary and the nixpkgs attributes that headline
it — which the profile README at [github.com/h0ffmann](https://github.com/h0ffmann) renders daily
next to the lab's lock date. CI checks that every listed attribute resolves in the lab's pinned
nixpkgs.

## Flake outputs

<details>
<summary>Expand to see available outputs</summary>

```console
$ nix flake show github:h0ffmann/nix-config?dir=labs/pratico
├───checks
│   └───x86_64-linux
│       └───toolchain: CI test          # Fortran + MPI + NetCDF-4 smoke test
└───devShells
    └───x86_64-linux
        ├───default: development environment   # = pratico
        ├───pratico: development environment   # toolchain + zsh-ai + ai-jail
        └───ww3: development environment       # toolchain only

$ nix flake show github:h0ffmann/nix-config?dir=labs/publisher
├───checks
│   └───x86_64-linux
│       ├───docx: CI test                # the sample as .docx, asserted to be a real Word document
│       ├───filter: CI test
│       └───smoke: CI test
├───devShells
│   └───x86_64-linux
│       └───default: development environment
├───lib                                  # tex, python, tools, mkPdf, mkDocx, mkDocument, env per system
└───packages
    └───x86_64-linux
        ├───smoke: package
        ├───smoke-docx: package
        └───tex: package                 # the TeX Live environment

$ nix flake show github:h0ffmann/nix-config?dir=labs/lint
├───checks
│   └───x86_64-linux
│       └───versions: CI test          # every tool's --version, built in the sandbox
├───devShells
│   └───x86_64-linux
│       └───default: development environment
├───lib                                  # tools (the list) per system
└───packages
    └───x86_64-linux
        ├───versions: package
        └───hadolint, actionlint, shellcheck, ruff, pyflakes, cloc, coverage, pdoc: package

$ nix flake show github:h0ffmann/nix-config?dir=labs/agentic
├───checks
│   └───x86_64-linux
│       ├───gh-token: CI test           # the script's --self-test, in the sandbox
│       └───jail-run: CI test
├───devShells
│   └───x86_64-linux
│       └───default: development environment
├───lib                                  # tools, env (BWRAP_BIN), scripts per system
└───packages
    └───x86_64-linux
        ├───ocr: package                 # Open Code Review, from the tagged Go source
        └───gh-token, clip, clip-relay, jail-run: package

$ nix flake show github:h0ffmann/nix-config?dir=labs/cuda
├───checks
│   └───x86_64-linux
│       ├───setup-cuda-cache: CI test   # the scripts' --self-test, in the sandbox
│       └───setup-ml-venv: CI test
├───devShells
│   └───x86_64-linux
│       └───default: development environment
├───lib                                  # tools per system (x86_64-linux only)
└───packages
    └───x86_64-linux
        └───setup-cuda-cache, setup-ml-venv: package

$ nix flake show github:h0ffmann/nix-config        # legacy root
├───checks.x86_64-linux.build            # NixOS toplevel evaluates
├───devShells.x86_64-linux.default
├───formatter.x86_64-linux
└───nixosConfigurations.nixos
```

`aarch64-linux` and `aarch64-darwin` are declared for the labs too (`--all-systems`).

</details>

<details>
<summary>Using a lab from another repository</summary>

Three ways, all used by ww-lab:

```console
# 1. as a flake input (publisher exports lib.<system>.mkPdf; see labs/publisher/README.md)
inputs.publisher.url = "github:h0ffmann/nix-config?dir=labs/publisher";

# 2. as a sparse git submodule, only the lab checked out (labs/pratico/scripts/ww-lab-submodule.sh)
nix develop ./nix-config/labs/pratico#ww3

# 3. in GitHub Actions (build, upload and commit PDFs in one step)
- uses: h0ffmann/nix-config/labs/publisher@main
```

**Used by:** [ww-lab](https://github.com/h0ffmann/ww-lab) — its
[`flake.nix`](https://github.com/h0ffmann/ww-lab/blob/main/flake.nix) consumes `labs/publisher`
through `mkPdf`, [`.github/workflows/pubs.yml`](https://github.com/h0ffmann/ww-lab/blob/main/.github/workflows/pubs.yml)
is a complete caller of the action (tests and translation as `pre-build`, PDFs committed back to
`main`), and `labs/pratico` is its sparse submodule.
[marola](https://github.com/h0ffmann/marola) consumes `labs/lint` as a flake input with
`nixpkgs.follows`, appending `lint.lib.${system}.tools`, `agentic.lib.${system}.tools` and, on x86_64-linux,
`cuda.lib.${system}.tools` to its own dev shell.

</details>

## CI

GitHub-hosted runners only. [`ci.yml`](.github/workflows/ci.yml):

* **NixOS flake evaluates** — `nix flake check --no-build` on the root; nothing is built.
* **labs/<lab>** (matrix) — `nix flake check` with the lock required current: every devShell
  evaluates and every `checks.*` output is **built**; then `nixpkgs-fmt --check`, `statix`,
  `deadnix`, `shellcheck` on every script, justfile parse, and the lab's self-tests when it has
  them. Lint tools come from the lab's own locked nixpkgs.
* **workflows lint** — `actionlint`.
* **profile ping** — [`profile-ping.yml`](.github/workflows/profile-ping.yml), a reusable
  workflow: after a merged PR it sends one `repository_dispatch` (`activity`) to
  [h0ffmann/h0ffmann](https://github.com/h0ffmann/h0ffmann), which rebuilds the profile's
  recent-activity list right away instead of at its daily cron. Callers are one job
  (`profile-activity.yml`) in nix-config, marola, ww3-gpu and gcp-agentic-architect; each needs a
  `PROFILE_DISPATCH_TOKEN` secret (fine-grained PAT, Contents: read & write on the profile repo only).

Dependabot bumps the actions monthly.

## Credits

The layout of this README, the idea of one `<details>` table per environment, and more than one
habit in these flakes come straight from [Gabriel Volpe's `nix-config`](https://github.com/gvolpe/nix-config).
Thank you, Gabriel — go read his repo; it is the better one.

## License

MIT — see [`LICENSE`](LICENSE). That covers the flakes, scripts and documentation in this
repository; the software each lab pins comes from nixpkgs and upstream projects under their own
licences, and nothing here vendors their source. ww-lab and marola, the main consumers, are MIT
too. The README layout credited above is borrowed from Gabriel Volpe's repository, which is
Apache-2.0; no code was copied from it.
