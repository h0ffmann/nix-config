{
  description = "agentic — ai-jail, OpenCode, gh, and the host-side scripts (gh-token, clip, clip-relay, jail-run) for running coding agents sandboxed";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    ai-jail = {
      url = "github:akitaonrails/ai-jail";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, ai-jail, ... }:
    let
      inherit (nixpkgs) lib;
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      forAll = f: lib.genAttrs systems (s: f nixpkgs.legacyPackages.${s});

      # One script file, run from source by CI and wrapped here for consumers. `runtimeInputs`
      # never lists a tool the script's own --self-test fakes on PATH (the wrapper prepends
      # runtimeInputs, which would shadow the fake): gh-token finds `gh` on the caller's PATH,
      # jail-run finds `ai-jail` there.
      script = pkgs: name: runtimeInputs: pkgs.writeShellApplication {
        inherit name runtimeInputs;
        text = builtins.readFile ./scripts/${name};
      };
      scriptsFor = pkgs: rec {
        gh-token = script pkgs "gh-token" [ ];
        clip = script pkgs "clip" [ pkgs.coreutils ];
        clip-relay = script pkgs "clip-relay" [ pkgs.coreutils ];
        jail-run = script pkgs "jail-run" [ gh-token clip-relay ];
      };

      # ai-jail's test suite needs a working sandbox at build time, which the Nix build sandbox
      # does not provide — same override marola and labs/pratico use.
      aiJailFor = pkgs: ai-jail.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (_: { doCheck = false; });

      toolsFor = pkgs:
        let s = scriptsFor pkgs; in
        [ pkgs.gh pkgs.opencode s.gh-token s.clip ]
        ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
          (aiJailFor pkgs)
          pkgs.bubblewrap
          pkgs.wl-clipboard # clip / clip-relay sinks
          pkgs.xclip
          s.clip-relay
          s.jail-run
        ];

      envFor = pkgs: lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
        # ai-jail's own devShell sets this; it does not propagate when consumed as a package.
        BWRAP_BIN = "${pkgs.bubblewrap}/bin/bwrap";
      };

      selfTest = pkgs: drv: pkgs.runCommand "${drv.name}-self-test" { } ''
        ${drv}/bin/${drv.name} --self-test | tee "$out"
      '';
    in
    {
      lib = forAll (pkgs: {
        tools = toolsFor pkgs;
        env = envFor pkgs;
        scripts = scriptsFor pkgs;
      });

      packages = forAll scriptsFor;

      devShells = forAll (pkgs: {
        default = pkgs.mkShell ({
          name = "agentic";
          packages = toolsFor pkgs;
          shellHook = ''echo "agentic: gh $(gh --version | head -1 | cut -d' ' -f3) | $(command -v ai-jail >/dev/null && echo ai-jail || echo 'ai-jail: Linux only') | jail-run claude|opencode from a directory with .ai-jail"'';
        } // envFor pkgs);
      });

      # Built by `nix flake check`: the scripts' own --self-test runs, in the sandbox, against
      # fakes on PATH — no gh login, no ai-jail, no display needed.
      checks = forAll (pkgs:
        let s = scriptsFor pkgs; in
        {
          gh-token = selfTest pkgs s.gh-token;
          jail-run = selfTest pkgs s.jail-run;
        });
    };
}
