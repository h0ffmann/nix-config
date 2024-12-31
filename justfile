# recipes
default:
    @just --list

# rebuild
[group('nix')]
rb:
    @echo "Rebuilding NixOS configuration..."
    sudo nixos-rebuild switch --flake path:.

[group('nix')]
history:
    nix profile history --profile /nix/var/nix/profiles/system

[group('nix')]
fmt:
    # format the nix files in this repo
    nix fmt

# restore audio after sleep
audio:
    systemctl --user restart pipewire pipewire-pulse wireplumber

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

