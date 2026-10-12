{
  description = "picasso's site: Gleam on the JavaScript target with Lustre, bundled by esbuild";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      forAll = f: lib.genAttrs systems (s: f nixpkgs.legacyPackages.${s});

      # Hex packages are pinned by checksum in manifest.toml; everything else comes from here.
      toolsFor = pkgs: with pkgs; [
        gleam
        nodejs # gleam test and the prerender run on node
        esbuild
        just
        python3 # check.py, history.py
      ];
    in
    {
      devShells = forAll (pkgs: {
        default = pkgs.mkShell { packages = toolsFor pkgs; };
      });

      # The build itself needs the Hex registry, so it runs in the dev shell, not the sandbox;
      # this only proves the pinned toolchain still builds and runs.
      checks = forAll (pkgs: {
        tools = pkgs.runCommand "site-tools" { nativeBuildInputs = toolsFor pkgs; } ''
          {
            gleam --version
            echo "node $(node --version)"
            echo "esbuild $(esbuild --version)"
            just --version
          } | tee "$out"
        '';
      });

      formatter = forAll (pkgs: pkgs.nixpkgs-fmt);
    };
}
