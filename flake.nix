{
  description = "A simple NixOS flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, home-manager }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # Import your main configuration
        {
          imports = [
            ./configuration.nix
            ./hardware-configuration.nix
            ./vscode.nix
          ];
        }
        # Import home-manager module
        home-manager.nixosModules.home-manager
      ];
    };
  };
}
