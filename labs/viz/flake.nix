{
  description = "viz — graphify, the code graph of a repository: code-only, keyless, offline";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # locked to the same rev as labs/gleam-website
  };

  outputs = { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      forAll = f: lib.genAttrs systems (s: f nixpkgs.legacyPackages.${s});

      # extract / cluster-only / update re-exec themselves to pin PYTHONHASHSEED, and the re-exec
      # loses the nixpkgs wrapper ("No module named graphify"), so the seed is set before they start.
      graphifyFor = pkgs: pkgs.symlinkJoin {
        name = "graphify-${pkgs.graphify.version}";
        paths = [ pkgs.graphify ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = "wrapProgram $out/bin/graphify --set-default PYTHONHASHSEED 0";
      };

      # graphify is baked in rather than listed in runtimeInputs, which would shadow the self-test's fake.
      vizFor = pkgs: pkgs.writeShellApplication {
        name = "viz";
        runtimeInputs = [ pkgs.coreutils pkgs.git ];
        text = builtins.replaceStrings [ "@graphify@" ] [ "${graphifyFor pkgs}/bin/graphify" ] (builtins.readFile ./scripts/viz);
        meta.license = lib.licenses.agpl3Only;
      };

      toolsFor = pkgs: [ (graphifyFor pkgs) (vizFor pkgs) ];

      # `nix flake check` builds this: graphify graphs example/ in the sandbox, with no network.
      smokeFor = pkgs: pkgs.runCommand "viz-smoke" { nativeBuildInputs = toolsFor pkgs; } ''
        export HOME=$TMPDIR VIZ_OUT=$TMPDIR/graph
        cp -r ${./example} example && chmod -R u+w example
        viz build example
        test -s "$VIZ_OUT/graph.json" && test -s "$VIZ_OUT/graph.html"
        viz query "greet" | tee query.txt
        grep -q greet query.txt
        mkdir -p "$out" && cp "$VIZ_OUT/graph.json" "$VIZ_OUT/graph.html" query.txt "$out"/
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

      devShells = forAll (pkgs: {
        default = pkgs.mkShell {
          name = "viz";
          packages = toolsFor pkgs;
          shellHook = ''echo "viz: graphify ${pkgs.graphify.version} | viz build, viz query \"<q>\""'';
        };
      });

      packages = forAll (pkgs: {
        default = vizFor pkgs;
        viz = vizFor pkgs;
        graphify = graphifyFor pkgs;
        smoke = smokeFor pkgs;
      });

      checks = forAll (pkgs: {
        lab-json = labCardFor pkgs;
        viz = pkgs.runCommand "viz-self-test" { } ''
          ${vizFor pkgs}/bin/viz --self-test | tee "$out"
        '';
        smoke = self.packages.${pkgs.stdenv.hostPlatform.system}.smoke;
      });
    };
}
