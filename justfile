# load environment variables from .env file
set dotenv-load

# recipes
default:
    @just --list


# rebuild
[group('nix')]
rb:
    @echo "Rebuilding NixOS configuration..."
    sudo nixos-rebuild switch --flake "$(pwd)"


[group('nix')]
history:
    nix profile history --profile /nix/var/nix/profiles/system


# format the nix files in this repo
[group('nix')]
fmt:
    nix fmt


# format the nix files in this repo
[group('nix')]
gc:
    sudo nix-collect-garbage -d


# boot the workstation in a QEMU VM; shares this checkout, ~/.claude, ~/repos and gh's token
[group('vm')]
vm:
    #!/usr/bin/env bash
    set -euo pipefail
    # without KVM, QEMU falls back to TCG and the desktop is unusable; on Ubuntu the fix is the kvm group
    if [ ! -w /dev/kvm ] && [ -z "${VM_NO_KVM:-}" ]; then
      echo "just vm: /dev/kvm is not writable; run: sudo usermod -aG kvm \"\$USER\", log in again (VM_NO_KVM=1 boots anyway, slowly)" >&2
      exit 1
    fi
    nix build "$(just _flake)#nixosConfigurations.nixos.config.system.build.vm"
    mkdir -p "$HOME/.claude"
    export VM_REPOS="${VM_REPOS:-$HOME/repos}"
    mkdir -p "$VM_REPOS" && touch "$VM_REPOS/.vm-repos"
    args=()
    if command -v gh >/dev/null && gh auth token >/dev/null 2>&1; then
      exec 3< <(gh auth token)
      args=(-fw_cfg name=opt/gh-token,file=/dev/fd/3)
    fi
    VM_NIX_CONFIG="$PWD" VM_CLAUDE_DIR="$HOME/.claude" ./result/bin/run-nixos-vm "${args[@]}"


# code graph of this repo, the marola-devkit way: build | query "<q>" | path <a> <b> | explain <x>
[group('agents')]
[positional-arguments]
graphify cmd="build" *args:
    #!/usr/bin/env bash
    set -euo pipefail
    shift
    out="${XDG_CACHE_HOME:-$HOME/.cache}/marola-graph/nix-config"
    bin="$(nix build --no-link --print-out-paths "$(just _flake)#graphify")/bin/graphify"
    # code-only, no API key, no model: the LLM pass over docs is what costs tokens
    g() { env -i PATH="$PATH" HOME="$out" GRAPHIFY_OUT="$out" GRAPHIFY_NO_AUTO_REFRESH=1 \
      OLLAMA_BASE_URL=http://127.0.0.1:9 "$bin" "$@"; }
    case "{{cmd}}" in
      build) mkdir -p "$out"
             g extract . --code-only --no-label
             g cluster-only . --no-label --graph "$out/graph.json" ;;
      query) g query "$@" --graph "$out/graph.json" --budget 400 ;;
      *) g "{{cmd}}" "$@" --graph "$out/graph.json" ;;
    esac


# the flake ref for this checkout: a shallow clone (ww3-gpu's submodule) has no revCount,
# and nix's git fetcher refuses it unless the ref says ?shallow=1
_flake:
    @if [ "$(git rev-parse --is-shallow-repository)" = true ]; then echo "git+file://$PWD?shallow=1"; else echo .; fi


# delete the VM's disk (nixos.qcow2); the next `just vm` starts from a fresh one
[group('vm')]
vm-reset:
    rm -f nixos.qcow2


# list the vendored agent skills and the ones to ask for to improve this repo
[group('agents')]
skills:
    @echo "Vendored skills (.claude/skills):"
    @awk -F'|' '/^\| `/ { gsub(/[ `]/, "", $2); gsub(/^ +| +$/, "", $6); printf "  %-22s %s\n", $2, $6 }' .claude/skills/README.md
    @echo
    @echo "Ask for these by name to improve this repo:"
    @sed -n '/^## On demand/,/^Licence/p' .claude/skills/README.md | grep '^- ' | sed 's/^- /  /; s/`//g'


# regenerate CITATION.cff from .zenodo.json (`just citation --check` to only verify)
[group('metadata')]
citation *args:
    python3 scripts/citation.py {{ args }}


# restore audio after sleep
audio:
    systemctl --user restart pipewire pipewire-pulse wireplumber


# m down
ydla id:
    yt-dlp https://www.youtube.com/watch?v={{id}} --extract-audio


# dump main files, usefull for LLM debugging
mix:
    repomix
    @cat nixos.md | xclip -selection clipboard
    @echo "Contents of nixos.md copied to clipboard"

# Code quality analysis with custom instruction file
mixcq:
    @cp repomix.config.json code-quality.config.json
    @sed -i 's/"instructionFilePath": "repomix-instruction.md"/"instructionFilePath": "code-quality-instruction.md"/g' code-quality.config.json
    @repomix --config code-quality.config.json
    @cat nixos.md | xclip -selection clipboard
    @echo "CODE QUALITY: Contents of nixos.md copied to clipboard"
