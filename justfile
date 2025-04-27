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
dump:
    @echo "=== configuration.nix ==="
    @cat /etc/nixos/configuration.nix
    @echo -e "\n=== home.nix ==="
    @cat /etc/nixos/home.nix
    @echo -e "\n=== flake.nix ==="
    @cat /etc/nixos/flake.nix


# dump all files, usefull for LLM debugging
dump-full:
    @echo "=== configuration.nix ==="
    @cat /etc/nixos/configuration.nix
    @echo -e "\n=== home.nix ==="
    @cat /etc/nixos/home.nix
    @echo -e "\n=== vscode.nix ==="
    @cat /etc/nixos/vscode.nix
    @echo -e "\n=== flake.nix ==="
    @cat /etc/nixos/flake.nix
    @echo -e "\n=== hardware-configuration.nix ==="
    @cat /etc/nixos/hardware-configuratio.nix


# run claude with mcp debug mode
claude:
    @claude --mcp-debug

# run brave browser with MCP server
brave-browser-run:
    @$HOME/.npm-global/bin/mcp-server-brave-search

# rebuild dev-shell
rebuild-devshell:
    @echo "Rebuilding development shell..."
    @cd /etc/nixos && nix develop .#impure
