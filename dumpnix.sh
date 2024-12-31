#!/bin/sh
echo "=== configuration.nix ==="
cat /etc/nixos/configuration.nix 
echo -e "\n=== home.nix ==="
cat /etc/nixos/home.nix 
echo -e "\n=== flake.nix ==="
cat /etc/nixos/flake.nix
