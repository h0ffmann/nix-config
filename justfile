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


# restore audio after sleep
audio:
    systemctl --user restart pipewire pipewire-pulse wireplumber


# m down
ydla id:
    yt-dlp https://www.youtube.com/watch?v={{id}} --extract-audio


# dump main files, usefull for LLM debugging
dump:
    @echo "=== configuration.nix ==="
    @cat /etc/nixos/configuration.nix
    @echo -e "\n=== home.nix ==="
    @cat /etc/nixos/home.nix
    @echo -e "\n=== flake.nix ==="
    @cat /etc/nixos/flake.nix


# dump all files, usefull for LLM debugging
dump-full:
    @repomix . --output repo-content.txt
