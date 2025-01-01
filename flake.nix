{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  inputs.zotero-nix.url = "github:camillemndn/zotero-nix";

  outputs = { self, nixpkgs, home-manager, zotero-nix }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          {
            imports = [
              ./configuration.nix
              ./hardware-configuration.nix
              ./vscode.nix
              ./davinci.nix
            ];
            environment.systemPackages = [
              zotero-nix.packages.${system}.default
            ];
          }
          home-manager.nixosModules.home-manager

        ];
      };

      # checks.${system} = {
      #   # Check if the configuration builds
      #   build = self.nixosConfigurations.nixos.config.system.build.toplevel;

      #   # Add statix checks
      #   statix = pkgs.runCommand "statix-check" { } ''
      #     ${pkgs.statix}/bin/statix check ${self} --ignore repeated-keys
      #     touch $out
      #   '';
      # };

      # Optional: add formatter
      formatter.${system} = pkgs.nixpkgs-fmt;
    };
}
