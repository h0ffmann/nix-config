# Default recipe to show all available commands
default:
    @just --list

# rebuild
rb:
    @echo "Rebuilding NixOS configuration..."
    sudo nixos-rebuild switch --flake path:.

