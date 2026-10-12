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
        meta.license = pkgs.lib.licenses.agpl3Only;
      };
      # The nix libstdc++ is baked in, so the wrapper never shells out to `nix build` at run time.
      setupMlVenvFor = pkgs: pkgs.writeShellApplication {
        name = "setup-ml-venv";
        runtimeInputs = [ pkgs.python3 pkgs.coreutils pkgs.gnugrep pkgs.gnused ];
        text = builtins.replaceStrings [ "@libstdcxx@" ] [ "${pkgs.stdenv.cc.cc.lib}/lib" ] (builtins.readFile ./scripts/setup-ml-venv);
        meta.license = pkgs.lib.licenses.agpl3Only;
      };
      toolsFor = pkgs: [ (setupCudaCacheFor pkgs) (setupMlVenvFor pkgs) ];

      selfTest = pkgs: drv: pkgs.runCommand "${drv.name}-self-test" { } ''
        ${drv}/bin/${drv.name} --self-test | tee "$out"
      '';

      # lab.json, the card the profile README renders: its shape is asserted at evaluation, and the
      # build writes each headline attribute's version from this lab's own nixpkgs. Copied in every
      # lab, since a lab references nothing outside itself.
      labCardFor = pkgs:
        let
          card = lib.importJSON ./lab.json;
          version = attr: (lib.getAttrFromPath (lib.splitString "." attr) pkgs).version;
        in
        assert lib.assertMsg (lib.isString card.summary && card.summary != "" && lib.stringLength card.summary <= 100)
          "lab.json: summary must be one non-empty line of at most 100 characters";
        assert lib.assertMsg (lib.isList card.headline && card.headline != [ ] && lib.all lib.isString card.headline)
          "lab.json: headline must be a non-empty list of nixpkgs attribute paths";
        pkgs.writeText "lab-json" (lib.concatMapStrings (a: "${a} ${version a}\n") card.headline);
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
        lab-json = labCardFor pkgs;
        setup-cuda-cache = selfTest pkgs (setupCudaCacheFor pkgs);
        setup-ml-venv = selfTest pkgs (setupMlVenvFor pkgs);
      });
    };
}
