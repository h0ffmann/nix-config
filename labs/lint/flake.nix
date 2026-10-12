{
  description = "lint — the gate a repository runs before a PR: hadolint, actionlint, shellcheck, ruff, pyflakes, cloc, coverage.py, pdoc";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      forAll = f: lib.genAttrs systems (s: f nixpkgs.legacyPackages.${s});

      # The one place the tools are named. A consumer appends this to its own mkShell packages.
      toolsFor = pkgs: with pkgs; [
        hadolint
        actionlint
        shellcheck # actionlint shells out to it for `run:` blocks; without it findings vanish silently
        ruff
        python3Packages.pyflakes
        cloc
        python3Packages.coverage
        python3Packages.pdoc
      ];

      # `nix flake check` builds this: every tool answers --version in the sandbox, so a nixpkgs
      # bump that drops or breaks one fails here, not in a consumer's CI.
      versionsFor = pkgs: pkgs.runCommand "lint-versions" { nativeBuildInputs = toolsFor pkgs; } ''
        {
          echo "nixpkgs    ${nixpkgs.rev or "dirty"}"
          echo "hadolint   $(hadolint --version)"
          echo "actionlint $(actionlint -version | head -1)"
          echo "shellcheck $(shellcheck --version | sed -n 2p)"
          echo "ruff       $(ruff --version)"
          echo "pyflakes   $(pyflakes --version)"
          echo "cloc       $(cloc --version)"
          echo "coverage   $(coverage --version | head -1)"
          echo "pdoc       $(pdoc --version | head -1)"
        } | tee versions.txt
        mkdir -p "$out" && cp versions.txt "$out"/
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
      lib = forAll (pkgs: {
        tools = toolsFor pkgs;
      });

      packages = forAll (pkgs: {
        versions = versionsFor pkgs;
        inherit (pkgs) hadolint actionlint shellcheck ruff cloc;
        inherit (pkgs.python3Packages) pyflakes coverage pdoc;
      });

      devShells = forAll (pkgs: {
        default = pkgs.mkShell {
          name = "lint";
          packages = toolsFor pkgs;
          shellHook = ''echo "lint: ruff $(ruff --version | cut -d' ' -f2) | hadolint $(hadolint --version | cut -d' ' -f4) | actionlint $(actionlint -version)"'';
        };
      });

      checks = forAll (pkgs: {
        lab-json = labCardFor pkgs;
        versions = self.packages.${pkgs.stdenv.hostPlatform.system}.versions;
      });
    };
}
