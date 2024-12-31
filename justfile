# Default recipe to show all available commands
default:
    @just --list

# System Management
rebuild-switch:
    @echo "Rebuilding NixOS configuration..."
    sudo nixos-rebuild switch

rebuild-boot:
    @echo "Rebuilding NixOS configuration for next boot..."
    sudo nixos-rebuild boot

rebuild-test:
    @echo "Testing NixOS configuration..."
    sudo nixos-rebuild test

update:
    @echo "Updating all flake inputs..."
    nix flake update

# Home Manager
home-switch:
    @echo "Switching home-manager configuration..."
    home-manager switch

home-build:
    @echo "Building home-manager configuration..."
    home-manager build

# Garbage Collection
gc:
    @echo "Running garbage collection..."
    sudo nix-collect-garbage -d

gc-old generations:
    @echo "Removing old system generations..."
    sudo nix-collect-garbage --delete-old
    sudo nixos-rebuild boot

# Flake Management
flake-update:
    @echo "Updating flake.lock..."
    nix flake update

flake-check:
    @echo "Checking flake..."
    nix flake check

# Development Environment
shell:
    @echo "Entering development shell..."
    nix develop

# History and Rollback
list-generations:
    @echo "Listing system generations..."
    sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

rollback:
    @echo "Rolling back to previous generation..."
    sudo nixos-rebuild switch --rollback

# Disk Management
disk-usage:
    @echo "Showing Nix store disk usage..."
    nix-store --gc --print-dead
    df -h /nix/store

# Git Operations
save msg:
    @echo "Saving changes to git..."
    git add .
    git commit -m "{{msg}}"
    git push

# Maintenance
maintenance: gc gc-old
    @echo "Running full system maintenance..."

# Check Configuration
check-config:
    @echo "Checking NixOS configuration..."
    sudo nixos-rebuild dry-build

# Custom Multi-Command Recipes
full-update: update gc home-switch rebuild-switch
    @echo "Full system update complete"

quick-save msg="update": check-config save
    @echo "Configuration checked and saved"

# Development Tasks
dev-shell:
    @echo "Starting development environment..."
    nix develop

dev-build:
    @echo "Building development environment..."
    nix build

# Show System Information
system-info:
    @echo "NixOS System Information:"
    nixos-version
    nix --version
    home-manager --version

# Check Security Updates
security-updates:
    @echo "Checking for security updates..."
    nix-channel --update nixos-unstable
    nix-env -f '<nixpkgs>' -u

# Help for specific commands
help:
    @echo "Available categories:"
    @echo "  system      - System management commands (rebuild-switch, rebuild-boot)"
    @echo "  home        - Home Manager commands (home-switch, home-build)"
    @echo "  gc          - Garbage collection commands (gc, gc-old)"
    @echo "  flake       - Flake management (flake-update, flake-check)"
    @echo "  dev         - Development commands (shell, dev-build)"
    @echo "  maintenance - Maintenance tasks (maintenance, full-update)"
    @echo "Use 'just <command>' to run a specific command"

# Usage Examples:
# just rebuild-switch        - Rebuild and switch to new configuration
# just home-switch          - Switch home-manager configuration
# just gc                   - Run garbage collection
# just save "commit message" - Save changes to git
# just full-update          - Run complete system update
# just quick-save           - Quick save with default commit message
