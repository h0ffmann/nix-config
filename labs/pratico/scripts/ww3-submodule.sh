#!/usr/bin/env bash
# ww3-submodule — keep a fork of NOAA-EMC/WW3 as a submodule of ww-lab, and keep that fork
# moving with upstream. The fork is the pin ww-lab builds against; upstream is where the
# real development (and its pull requests) happens.
#
#   scripts/ww3-submodule.sh ~/code/ww-lab                    # add the fork as ./WW3 (or init it)
#   scripts/ww3-submodule.sh ~/code/ww-lab --sync --push      # fork <- upstream/develop, push fork
#   scripts/ww3-submodule.sh ~/code/ww-lab --bump --commit    # ww-lab pin -> latest fork branch
#   scripts/ww3-submodule.sh ~/code/ww-lab --pr 1234          # check out upstream PR #1234 in WW3/
#   scripts/ww3-submodule.sh ~/code/ww-lab --sync --push --bump --commit   # the usual refresh
#
# Options
#   --fork <url>      your fork (default git@github.com:h0ffmann/WW3.git) — the submodule's origin
#   --upstream <url>  the original (default https://github.com/NOAA-EMC/WW3.git) — remote "upstream"
#   --path <dir>      submodule directory in ww-lab (default WW3)
#   --branch <name>   branch to track on both (default develop, WW3's integration branch)
#   --sync            fast-forward the fork's <branch> to upstream/<branch> (no merge commits;
#                     if the fork has its own commits, use --merge to merge upstream in)
#   --merge           with --sync: merge upstream instead of fast-forwarding
#   --push            with --sync: push the updated branch to the fork
#   --pr <n>          fetch upstream pull request <n> and check it out (detached) — pinning
#                     ww-lab to a PR that is not merged yet; --commit records it
#   --bump            move the pin to origin/<branch> of the fork
#   --commit          commit .gitmodules and the new pin in ww-lab
#
# Idempotent: rerun after a fresh clone (initialises the submodule), rerun to refresh.
set -euo pipefail

fork="git@github.com:h0ffmann/WW3.git"
upstream="https://github.com/NOAA-EMC/WW3.git"
path="WW3"
branch="develop"
sync=0 merge=0 push=0 bump=0 commit=0
pr=""
target=""

usage() { sed -n '2,25p' "$0"; }
need() { [ $# -ge 2 ] || { echo "ww3-submodule: $1 needs a value" >&2; exit 2; }; }

while [ $# -gt 0 ]; do
    case "$1" in
        --fork)     need "$@"; fork="$2"; shift ;;
        --upstream) need "$@"; upstream="$2"; shift ;;
        --path)     need "$@"; path="$2"; shift ;;
        --branch)   need "$@"; branch="$2"; shift ;;
        --pr)       need "$@"; pr="$2"; shift ;;
        --sync)     sync=1 ;;
        --merge)    merge=1 ;;
        --push)     push=1 ;;
        --bump)     bump=1 ;;
        --commit)   commit=1 ;;
        --help|-h)  usage; exit 0 ;;
        -*)         echo "ww3-submodule: unknown option '$1'" >&2; exit 2 ;;
        *)          [ -z "$target" ] || { echo "ww3-submodule: one target directory only" >&2; exit 2; }; target="$1" ;;
    esac
    shift
done
target="${target:-$PWD}"
[ "$merge" -eq 0 ] || [ "$sync" -eq 1 ] || { echo "ww3-submodule: --merge only makes sense with --sync" >&2; exit 2; }
[ "$push" -eq 0 ] || [ "$sync" -eq 1 ] || { echo "ww3-submodule: --push only makes sense with --sync" >&2; exit 2; }
[ -z "$pr" ] || [ "$bump" -eq 0 ] || { echo "ww3-submodule: --pr and --bump both move the pin — pick one" >&2; exit 2; }

git -C "$target" rev-parse --show-toplevel >/dev/null 2>&1 \
    || { echo "ww3-submodule: $target is not a git repository" >&2; exit 1; }
root="$(git -C "$target" rev-parse --show-toplevel)"
sub="$root/$path"
short() { git -C "$sub" rev-parse --short "$1"; }
# The pin ww-lab has committed for the submodule (what a bump is measured against), if any.
pinned() { git -C "$root" rev-parse --short "HEAD:$path" 2>/dev/null || short HEAD; }

# 1. The submodule: the fork is origin. Full history on purpose — --sync needs it to
#    fast-forward, and WW3's regtests and docs are what make the clone big, not the history.
if git -C "$root" config -f .gitmodules --get "submodule.$path.url" >/dev/null 2>&1; then
    echo "ww3-submodule: $path already in .gitmodules — initialising if needed"
    git -C "$root" submodule update --init -- "$path"
else
    echo "ww3-submodule: adding fork $fork at $path (branch $branch)"
    git -C "$root" submodule add -b "$branch" -- "$fork" "$path"
fi
git -C "$root" config -f .gitmodules "submodule.$path.branch" "$branch"

# 2. The original as a second remote inside the submodule, so the fork can follow it.
if git -C "$sub" remote get-url upstream >/dev/null 2>&1; then
    git -C "$sub" remote set-url upstream "$upstream"
else
    git -C "$sub" remote add upstream "$upstream"
fi

# 3. Fork <- upstream. Work on a real local branch so the result can be pushed to the fork.
if [ "$sync" -eq 1 ]; then
    git -C "$sub" fetch --quiet origin "$branch"
    git -C "$sub" fetch --quiet upstream "$branch"
    git -C "$sub" checkout --quiet -B "$branch" "origin/$branch"
    before="$(short HEAD)"
    if [ "$merge" -eq 1 ]; then
        git -C "$sub" merge --quiet --no-edit "upstream/$branch"
    elif ! git -C "$sub" merge --quiet --ff-only "upstream/$branch"; then
        echo "ww3-submodule: fork/$branch has diverged from upstream/$branch — rerun with --merge," >&2
        echo "               or rebase the fork's own commits by hand inside $sub" >&2
        exit 1
    fi
    after="$(short HEAD)"
    if [ "$before" = "$after" ]; then
        echo "ww3-submodule: fork/$branch already up to date with upstream ($after)"
    else
        echo "ww3-submodule: fork/$branch $before -> $after ($(git -C "$sub" rev-list --count "$before..$after") commits from upstream)"
    fi
    if [ "$push" -eq 1 ]; then
        git -C "$sub" push --quiet origin "$branch"
        echo "ww3-submodule: pushed $branch to fork"
    fi
fi

# 4. Where ww-lab's pin goes: an upstream PR head, or the fork's branch tip.
if [ -n "$pr" ]; then
    git -C "$sub" fetch --quiet upstream "refs/pull/$pr/head:refs/remotes/upstream/pr/$pr"
    git -C "$sub" checkout --quiet --detach "upstream/pr/$pr"
    echo "ww3-submodule: $path at upstream PR #$pr ($(short HEAD))"
elif [ "$bump" -eq 1 ]; then
    before="$(pinned)"
    git -C "$sub" fetch --quiet origin "$branch"
    git -C "$sub" checkout --quiet --detach "origin/$branch"
    after="$(short HEAD)"
    if [ "$before" = "$after" ]; then
        echo "ww3-submodule: pin already at fork/$branch ($after)"
    else
        echo "ww3-submodule: pin $before -> $after (fork/$branch)"
    fi
fi

# 5. Record it in ww-lab.
git -C "$root" add .gitmodules "$path"
if [ "$commit" -eq 1 ]; then
    if git -C "$root" diff --cached --quiet; then
        echo "ww3-submodule: nothing to commit"
    else
        what="fork/$branch"; [ -z "$pr" ] || what="upstream PR #$pr"
        git -C "$root" commit -q -m "WW3 submodule: $path @ $(short HEAD) ($what)"
        echo "ww3-submodule: committed"
    fi
else
    echo "ww3-submodule: staged .gitmodules and $path — commit when ready (or rerun with --commit)"
fi

echo "ww3-submodule: $sub -> $(short HEAD)  origin=$(git -C "$sub" remote get-url origin)  upstream=$(git -C "$sub" remote get-url upstream)"
echo "  nix develop ./nix-config/labs/pratico#ww3 --command cmake -S $path/model -B build -DSWITCH=... -DCMAKE_INSTALL_PREFIX=install"
