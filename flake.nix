{
  description = "A simple NixOS flake";

  # https://pyproject-nix.github.io/uv2nix/usage/hello-world.html
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.uv2nix.follows = "uv2nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  inputs.zotero-nix.url = "github:camillemndn/zotero-nix";

  outputs =
    { self
    , nixpkgs
    , home-manager
    , zotero-nix
    , uv2nix
    , pyproject-nix
    , pyproject-build-systems
    , ...
    }:
    let
      inherit (nixpkgs) lib;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      workspace = uv2nix.lib.workspace.loadWorkspace { workspaceRoot = ./.; };
      overlay = workspace.mkPyprojectOverlay {
        sourcePreference = "wheel"; # or sourcePreference = "sdist";
      };
      pyprojectOverrides = _final: _prev: {
        # Implement build fixups here.
      };
      python = pkgs.python312;
      pythonSet =
        # Use base package set from pyproject.nix builders
        (pkgs.callPackage pyproject-nix.build.packages {
          inherit python;
        }).overrideScope
          (
            lib.composeManyExtensions [
              pyproject-build-systems.overlays.default
              overlay
              pyprojectOverrides
            ]
          );
    in
    {
      packages.x86_64-linux.default = pythonSet.mkVirtualEnv "hello-world-env" workspace.deps.default;

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
              pkgs.calibre
            ];
          }
          home-manager.nixosModules.home-manager

        ];
      };

      devShells.x86_64-linux = {
        impure = pkgs.mkShell {
          packages = [
            python
            pkgs.uv
          ];
          shellHook = ''
            unset PYTHONPATH
            export UV_PYTHON_DOWNLOADS=never
          '';
        };
        uv2nix =
          let
            editableOverlay = workspace.mkEditablePyprojectOverlay {
              root = "$REPO_ROOT";
            };

            editablePythonSet = pythonSet.overrideScope editableOverlay;
            virtualenv = editablePythonSet.mkVirtualEnv "hello-world-dev-env" workspace.deps.all;

          in
          pkgs.mkShell {
            packages = [
              virtualenv
              pkgs.uv
            ];
            shellHook = ''
              # Undo dependency propagation by nixpkgs.
              unset PYTHONPATH

              # Don't create venv using uv
              export UV_NO_SYNC=1

              # Prevent uv from downloading managed Python's
              export UV_PYTHON_DOWNLOADS=never

              # Get repository root using git. This is expanded at runtime by the editable `.pth` machinery.
              export REPO_ROOT=$(git rev-parse --show-toplevel)
            '';
          };
      };
      checks.${system} = {
        # Check if the configuration builds
        build = self.nixosConfigurations.nixos.config.system.build.toplevel;

        # Add statix checks
        statix = pkgs.runCommand "statix-check" { } ''
          ${pkgs.statix}/bin/statix check ${self} --ignore repeated-keys
          touch $out
        '';
      };

      # Optional: add formatter
      formatter.${system} = pkgs.nixpkgs-fmt;
    };
}
