#!/usr/bin/env bash
# ww-lab-submodule — wire nix-config into a consumer repo (ww-lab) as a git submodule with
# only labs/pratico checked out. Git cannot submodule a subdirectory, so the submodule points
# at the whole repo and sparse-checkout keeps everything but labs/pratico off disk.
#
# Idempotent: run it once to add the submodule, again after a fresh clone to materialise it,
# and with --bump to move the pin to the latest origin/<branch>. Every git call is explicit
# about its directory, so run it from anywhere.
#
#   scripts/ww-lab-submodule.sh ~/code/ww-lab                 # add or (re)initialise
#   scripts/ww-lab-submodule.sh ~/code/ww-lab --bump          # pin to latest origin/main
#   scripts/ww-lab-submodule.sh ~/code/ww-lab --branch feat/x # track a branch (before merge)
#   scripts/ww-lab-submodule.sh ~/code/ww-lab --commit        # also commit .gitmodules + pin
#
# Sparse-checkout is local state, not recorded in .gitmodules, which is why fresh clones
# need this script (or `git -C nix-config sparse-checkout set labs/pratico`) once.
set -euo pipefail

url="git@github.com:h0ffmann/nix-config.git"
path="nix-config"
sparse="labs/pratico"
branch="main"
bump=0
commit=0
target=""

usage() { sed -n '2,17p' "$0"; }

while [ $# -gt 0 ]; do
    case "$1" in
        --bump)     bump=1 ;;
        --commit)   commit=1 ;;
        --branch)   [ $# -ge 2 ] || { echo "ww-lab-submodule: --branch needs a value" >&2; exit 2; }; branch="$2"; shift ;;
        --url)      [ $# -ge 2 ] || { echo "ww-lab-submodule: --url needs a value" >&2; exit 2; }; url="$2"; shift ;;
        --path)     [ $# -ge 2 ] || { echo "ww-lab-submodule: --path needs a value" >&2; exit 2; }; path="$2"; shift ;;
        --help|-h)  usage; exit 0 ;;
        -*)         echo "ww-lab-submodule: unknown option '$1'" >&2; exit 2 ;;
        *)          [ -z "$target" ] || { echo "ww-lab-submodule: one target directory only" >&2; exit 2; }; target="$1" ;;
    esac
    shift
done
target="${target:-$PWD}"

git -C "$target" rev-parse --show-toplevel >/dev/null 2>&1 \
    || { echo "ww-lab-submodule: $target is not a git repository" >&2; exit 1; }
root="$(git -C "$target" rev-parse --show-toplevel)"
sub="$root/$path"

# 1. The submodule entry. Present in .gitmodules → make sure it is initialised; absent → add.
if git -C "$root" config -f .gitmodules --get "submodule.$path.url" >/dev/null 2>&1; then
    echo "ww-lab-submodule: $path already in .gitmodules — initialising if needed"
    git -C "$root" submodule update --init --depth 1 -- "$path"
else
    echo "ww-lab-submodule: adding $url at $path (branch $branch)"
    git -C "$root" submodule add --depth 1 -b "$branch" -- "$url" "$path"
fi
# Recorded in .gitmodules, so every clone fetches shallow and knows which branch to follow.
git -C "$root" config -f .gitmodules "submodule.$path.shallow" true
git -C "$root" config -f .gitmodules "submodule.$path.branch" "$branch"

# 2. Only labs/pratico on disk. Non-cone mode on purpose: cone mode always materialises the
# repo's top-level files (flake.nix, configuration.nix, ...), which is exactly the noise a
# consumer should not see. The leading slash anchors the pattern at the repo root.
git -C "$sub" sparse-checkout set --no-cone "/$sparse/"

# 3. Optionally move the pin to the tip of the tracked branch.
if [ "$bump" -eq 1 ]; then
    before="$(git -C "$sub" rev-parse HEAD)"
    git -C "$sub" fetch --depth 1 origin "$branch"
    git -C "$sub" checkout --quiet --detach FETCH_HEAD
    after="$(git -C "$sub" rev-parse HEAD)"
    if [ "$before" = "$after" ]; then
        echo "ww-lab-submodule: already at origin/$branch (${after:0:7})"
    else
        echo "ww-lab-submodule: ${before:0:7} -> ${after:0:7} (origin/$branch)"
    fi
fi

# 4. Stage what the consumer repo must commit: .gitmodules and the submodule pointer.
git -C "$root" add .gitmodules "$path"
if [ "$commit" -eq 1 ]; then
    if git -C "$root" diff --cached --quiet; then
        echo "ww-lab-submodule: nothing to commit"
    else
        git -C "$root" commit -q -m "nix-config submodule: $path @ $(git -C "$sub" rev-parse --short HEAD) ($sparse only)"
        echo "ww-lab-submodule: committed"
    fi
else
    echo "ww-lab-submodule: staged .gitmodules and $path — commit when ready (or rerun with --commit)"
fi

[ -d "$sub/$sparse" ] || { echo "ww-lab-submodule: $sub/$sparse is missing after checkout" >&2; exit 1; }
echo "ww-lab-submodule: $sub -> $(git -C "$sub" rev-parse --short HEAD), checked out: $(git -C "$sub" sparse-checkout list | tr '\n' ' ')"
echo "  nix develop $path/$sparse#ww3"
echo "  just -f $path/$sparse/justfile toolchain"
