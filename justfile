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