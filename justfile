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


# boot the workstation in a QEMU VM, with this checkout, ~/.claude and gh's token shared in
[group('vm')]
vm:
    #!/usr/bin/env bash
    set -euo pipefail
    nix build .#nixosConfigurations.nixos.config.system.build.vm
    mkdir -p "$HOME/.claude"
    args=()
    if command -v gh >/dev/null && gh auth token >/dev/null 2>&1; then
      exec 3< <(gh auth token)
      args=(-fw_cfg name=opt/gh-token,file=/dev/fd/3)
    fi
    VM_NIX_CONFIG="$PWD" VM_CLAUDE_DIR="$HOME/.claude" ./result/bin/run-nixos-vm "${args[@]}"


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
