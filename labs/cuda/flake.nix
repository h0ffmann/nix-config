{
  description = "cuda — host setup for a CUDA box: the nixos-cuda binary cache in nix.custom.conf, and a torch venv from PyTorch's wheel index with libstdc++ and the driver libraries on its path";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;
      systems = [ "x86_64-linux" ]; # CUDA wheels and the driver-library layout are x86_64 Linux only
      forAll = f: lib.genAttrs systems (s: f nixpkgs.legacyPackages.${s});

      setupCudaCacheFor = pkgs: pkgs.writeShellApplication {
        name = "setup-cuda-cache";
        runtimeInputs = [ pkgs.coreutils pkgs.gnused pkgs.gnugrep ];
        text = builtins.readFile ./scripts/setup-cuda-cache;
      };
      # The nix libstdc++ is baked in, so the wrapper never shells out to `nix build` at run time.
      setupMlVenvFor = pkgs: pkgs.writeShellApplication {
        name = "setup-ml-venv";
        runtimeInputs = [ pkgs.python3 pkgs.coreutils pkgs.gnugrep pkgs.gnused ];
        text = builtins.replaceStrings [ "@libstdcxx@" ] [ "${pkgs.stdenv.cc.cc.lib}/lib" ] (builtins.readFile ./scripts/setup-ml-venv);
      };
      toolsFor = pkgs: [ (setupCudaCacheFor pkgs) (setupMlVenvFor pkgs) ];

      selfTest = pkgs: drv: pkgs.runCommand "${drv.name}-self-test" { } ''
        ${drv}/bin/${drv.name} --self-test | tee "$out"
      '';
    in
    {
      lib = forAll (pkgs: { tools = toolsFor pkgs; });

      packages = forAll (pkgs: {
        setup-cuda-cache = setupCudaCacheFor pkgs;
        setup-ml-venv = setupMlVenvFor pkgs;
      });

      devShells = forAll (pkgs: {
        default = pkgs.mkShell {
          name = "cuda";
          packages = toolsFor pkgs;
          shellHook = ''echo "cuda: setup-cuda-cache --dry-run | REQUIREMENTS=<file> setup-ml-venv"'';
        };
      });

      # The generic halves only: no GPU, no root, no network in the sandbox.
      checks = forAll (pkgs: {
        setup-cuda-cache = selfTest pkgs (setupCudaCacheFor pkgs);
        setup-ml-venv = selfTest pkgs (setupMlVenvFor pkgs);
      });
    };
}
