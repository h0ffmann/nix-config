# AGENTS.md

Instructions for any AI coding agent working in this repository (Claude Code, OpenCode or
otherwise). Read this before writing, modifying or running anything. Humans should read it too.

## What this repo is

Self-contained Nix flakes ("labs") for the toolchains I work in, on an Ubuntu workstation
(i9 + RTX 4090) running Determinate Nix — **not NixOS**. Other repositories borrow a lab as a
flake input, a sparse git submodule, or a GitHub Action; CI builds each lab on every push.
`README.md` is the map: one section per lab, a `<details>` table of what it pins, then Structure,
Flake outputs, how consumers use a lab, CI. `DESCRIPTION.md` is the one-paragraph version.

The layout and the README style come from [gvolpe/nix-config](https://github.com/gvolpe/nix-config):
a README that is a catalogue of environments rather than a manual, one `<details>` table per
environment, `notes/` for things worth writing down once, and a flake whose outputs are listed
in the README verbatim. What is *not* borrowed: gvolpe's is a NixOS + Home Manager system;
this repo's root system configuration is legacy (see below) and the living part is `labs/`.

| Lab | Is | Consumer |
|---|---|---|
| `labs/pratico` | WAVEWATCH III toolchain (gfortran / OpenMPI / NetCDF), zsh-ai pilot, ai-jail recipes | [ww-lab](https://github.com/h0ffmann/ww-lab) (sparse submodule) |
| `labs/publisher` | pandoc + TeX Live, `mkPdf`, a composite Action that builds and commits PDFs | ww-lab (flake input + Action) |
| `labs/lint` | hadolint, actionlint, shellcheck, ruff, pyflakes, cloc, coverage, pdoc — a list, no scripts | [marola](https://github.com/h0ffmann/marola) (flake input) |
| `labs/agentic` | ai-jail, OpenCode, gh, and `jail-run` / `gh-token` / `clip` / `clip-relay` | marola (landing via #50) |
| `labs/cuda` | nixos-cuda binary cache setup, torch venv with the driver libs on its path; x86_64-linux only | marola, this workstation (landing via #50) |

## The lab contract (hard rule)

A lab is one directory with its own `flake.nix`, `flake.lock`, `justfile`, `README.md` and
`lab.json`, and it **references nothing outside itself** — no `../`, no shared `lib/`, no root flake input. That is
what lets ww-lab check out `labs/pratico` alone as a sparse submodule and lets marola pin
`?dir=labs/lint`. If two labs want to share code, copy it; a change that makes a lab depend on
another is wrong even when it removes duplication.

Every lab exports the same shape, so a consumer that learnt one can use the others:
`devShells.<system>.default` (and named shells where it makes sense: `pratico`'s `ww3`),
`lib.<system>.tools` (the package list, for `++` into a consumer's own `mkShell`),
`packages.<system>.<tool-or-script>`, and `checks.<system>.*` — and every check must **build**
in the Nix sandbox, because CI builds it. `aarch64-linux` and `aarch64-darwin` are declared
unless the lab genuinely cannot (`cuda`); use `lib.optionals pkgs.stdenv.hostPlatform.isLinux`
rather than dropping a system.

A lab's `nixpkgs` follows `nixos-unstable` and its lock is committed; **CI runs with
`--no-update-lock-file`, so a lock that is behind the flake fails, not warns.** Bump with
`nix flake update` inside the lab and commit the lock in the same PR as the change that needed it.

`lab.json` is the lab's card for the profile README at [github.com/h0ffmann](https://github.com/h0ffmann),
which renders every lab's lock date and headline versions daily: `summary` (one line, at most
100 characters) and `headline` (nixpkgs attribute paths whose `.version` is shown, e.g.
`"cudaPackages.cudatoolkit"`). Only nixpkgs attributes belong there, never a flake input such as
ai-jail, so the file is readable from `flake.lock` alone without evaluating the lab. CI checks the
shape and that every attribute resolves in the lab's pinned nixpkgs.

Scripts (`labs/<lab>/scripts/*`) are one file each, `#!/usr/bin/env bash`, `set -euo pipefail`,
run **from source** by CI and wrapped with `writeShellApplication` for consumers. Each has a
`--self-test` mode that fakes its external commands on `PATH`; CI runs every self-test it finds
and `nix flake check` runs them again in the sandbox. Trap: `runtimeInputs` must never list a
tool the self-test fakes, since the wrapper prepends `runtimeInputs` and would shadow the fake
(`labs/agentic/flake.nix` says which tools each script resolves from the caller's `PATH` instead).

## Setup & commands

```console
cd labs/<lab>
just                  # the lab's recipes
just shell            # (lint, publisher, agentic, cuda) the tools on PATH, in your current directory
just ww3 / just dev   # (pratico) toolchain-only / interactive shell
just versions         # (lint, publisher) what is pinned
just smoke            # (pratico, publisher) the check CI builds
just self-test        # (agentic, cuda) every script's --self-test, from source
```

Definition of done for any change under `labs/<lab>` is the CI gate in
`.github/workflows/ci.yml`, run locally from the lab directory before the PR:

```console
nix flake check --no-update-lock-file --print-build-logs .
nix run nixpkgs#nixpkgs-fmt -- --check .     # ci resolves the lab's own locked nixpkgs; same tools
nix run nixpkgs#statix -- check .
nix run nixpkgs#deadnix -- --fail .
nix run nixpkgs#shellcheck -- scripts/*      # when the lab has scripts
just --list                                  # justfile parses
nix run nixpkgs#actionlint                   # after any .github/** change
```

Format with `nixpkgs-fmt` (the root flake's `formatter`), never another formatter.

## Adding or changing a lab — the checklist

A new lab touches six places, and a PR that misses one is incomplete:

1. `labs/<lab>/` with the five files above (+ `scripts/`, `.gitignore` as needed).
2. `README.md`: a `## <lab>` section in the existing shape — one paragraph, a `console` block of
   the `just` recipes, a `<details>` table of what it pins with links to each upstream — plus its
   line in **Structure** and its `nix flake show` block in **Flake outputs**.
3. `.github/workflows/ci.yml`: the lab's name in the `labs` matrix. Nothing else in CI is per-lab.
4. `DESCRIPTION.md` if the one-paragraph summary changed.
5. A consumer, if one exists, gets the new pin (`nix flake update <input>` in ww-lab / marola).
6. `labs/<lab>/README.md` has a "Reusing it from another repository" section with the exact
   `inputs.<lab>.url = "github:h0ffmann/nix-config?dir=labs/<lab>"` block.

Breaking a lab's exported shape (`lib.<system>.tools`, `mkPdf`'s arguments, a script's flags)
breaks ww-lab and marola on their next `nix flake update`. Say so in the PR and open the
consumer's PR alongside.

## The legacy root (do not develop here)

`flake.nix`, `configuration.nix`, `hardware-configuration.nix`, `home.nix`, `vscode.nix`,
`davinci.nix`, `dev-shell.nix`, `supabase-package.nix`, `cachix*`, `repomix*`, `code-quality*`
and the root `justfile` are the NixOS system this machine used to run; `notes/legacy-nixos-root.md`
documents them. CI only checks that the root flake still **evaluates**. Do not extend it, do not
run `just rb` / `nixos-rebuild` (there is no NixOS to rebuild), and do not move a lab's concern
into it. Deleting it is a decision for the human, not a cleanup for an agent.

## Safety (hard rules)

- **Nothing here applies to the host without a human.** `sudo just cache-setup apply`,
  `setup-cuda-cache` without `--dry-run`, anything that writes `/etc/nix/*`, restarts
  `nix-daemon`, or runs `nix-collect-garbage`: propose, show the dry-run, wait for a go-ahead.
  Determinate Nix marks `nix.conf` "do not modify"; the only file a script may write is
  `nix.custom.conf`, and only `setup-cuda-cache` does that.
- **Never commit a token or a `.env`.** `gh-token` prints a token to stdout by design — never
  paste its output into a file, a log, a PR or a commit. `.env` is gitignored; keep it that way.
- **Inside ai-jail, never `gh auth login`.** `~/.config/gh` is not mapped in, so the login lands
  in an ephemeral HOME and is gone next session. Authenticate once on the host; `jail-run`
  forwards the token as `GH_TOKEN`.
- **No `--no-verify`, no force-push to `main`.** Stacked branches (`labs/*`) merge into `main`,
  not into each other — #47/#48 merged into their stacked bases and needed #50 to land on
  `main`; retarget a stacked PR before merging its base.
- Don't build ai-jail or ParMETIS just to prove a devShell works: CI evaluates devShells and
  builds only `checks.*`, deliberately, so a Rust compile and a CUDA download stay off the
  runner. Match that locally unless the change is to those packages.

## Commits and PRs

Commit subject in the `<type>(<lab>): ...` shape the log already uses — `feat(cuda): ...`,
`docs: ...`, `ci: ...` — with a body that carries the reasoning, then exactly these trailers:

```
Tested: <what was run and its result — or "n/a — documentation">
Co-Authored-By: Claude <noreply@anthropic.com>
```

No session links, no "Generated with" banners. The `Tested:` line names the real command and
its outcome; if the gate was not run, say so rather than implying it passed. PR descriptions
state what a consumer has to do, if anything, when the change lands.

## Comments

Write few, and only what the code cannot say: a why (a rejected alternative, a constraint from
outside the file — Determinate Nix's `!include`, ai-jail's `--env` semantics), a trap (the
`runtimeInputs` shadowing above), or a pointer (the PR that explains the shape). A script header
that documents its flags and the one non-obvious decision is the right size; a paragraph
restating what the next twenty lines do is not. The commit message is the home for history.

## When something here turns out to be wrong

Update this file, the lab's README and the root README in the same change — a pinned tool
moves, Determinate Nix changes where custom config lives, a consumer stops using a lab. This
file is read by non-Claude agents too, so a rule that matters stays here even if a longer
explanation lives in a lab README or `notes/`.
