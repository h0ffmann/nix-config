# nix-config, described

Copy-paste text for LinkedIn (a post, a shorter "about" version, and a one-liner). Plain
paragraphs on purpose: LinkedIn renders no Markdown, so nothing here depends on it.

Repository: https://github.com/h0ffmann/nix-config

---

## The post

I keep my development environments as Nix "labs": small, self-contained flakes for the tools
I actually work in, on an Ubuntu workstation (i9 + RTX 4090) running Determinate Nix.

Each lab is one directory with its own flake.nix, flake.lock, justfile and README. It
references nothing outside itself, so any repository can consume it three ways: as a flake
input, as a sparse git submodule, or as a GitHub Action. My WAVEWATCH III course material
(ww-lab) uses all three.

What is in there today:

prático: the WAVEWATCH III toolchain (gfortran, OpenMPI, NetCDF-4, METIS, ecCodes) from one
locked nixpkgs, so a build on a laptop, in CI, or on a cluster login node links the same
compilers bit for bit. On top of it, an interactive shell with a local zsh pilot (zsh-ai to llm
to Ollama, Qwen coder) and ai-jail recipes for running Claude Code or OpenCode sandboxed.

publisher: Markdown to LaTeX to PDF, reproducibly. pandoc 3.7 and TeX Live 2025, a mkPdf
helper so other repositories build their documents in the Nix sandbox, and a composite GitHub
Action that builds, uploads and commits the PDFs in one step.

lint: the tools a repository runs before a PR (hadolint, actionlint, shellcheck, ruff,
pyflakes, cloc, coverage.py, pdoc), as one list. No scripts.

CI builds every lab's checks on every push, with the lock required current, then runs
nixpkgs-fmt, statix, deadnix and shellcheck from the lab's own pinned nixpkgs. A green badge
means the environments still exist, not just that they still evaluate.

The layout of the README, the idea of one details table per environment, and more than one
habit in these flakes come straight from Gabriel Volpe's nix-config
(https://github.com/gvolpe/nix-config). If you want to see how a NixOS and Home Manager setup
is documented well, start there. Mine is the applied, smaller cousin: no desktop, just the
toolchains a scientific-computing project needs, packaged so they can be borrowed.

---

## Short version

Nix "labs": self-contained flakes for a WAVEWATCH III toolchain (gfortran, OpenMPI, NetCDF),
a pandoc + TeX Live publishing pipeline with a GitHub Action, and a lint toolchain, each one
directory that any repository can consume as a flake input, a submodule, or an action. CI
builds every lab on every push. README layout and more than one habit borrowed, with thanks,
from Gabriel Volpe's nix-config (https://github.com/gvolpe/nix-config).

---

## One-liner

Reproducible toolchains for ocean-wave modelling and publishing, as borrowable Nix flakes,
documented the way gvolpe/nix-config taught me to.

---

## Hashtags

#Nix #NixOS #ReproducibleResearch #WAVEWATCHIII #Fortran #OpenMPI #NetCDF #LaTeX #DevOps
#OpenSource
