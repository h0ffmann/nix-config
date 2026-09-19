{
  description = "agentic — ai-jail, OpenCode, Open Code Review, gh, and the host-side scripts (gh-token, clip, clip-relay, jail-run) for running coding agents sandboxed";

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

      # alibaba/open-code-review's `ocr`, from source rather than the release binary: the module
      # wants `go 1.25.5` and this lab's nixpkgs carries Go 1.26, so buildGoModule works and the
      # build stays a source build on every system instead of an x86_64 blob. `rev` is the commit
      # the *annotated* tag v1.12.7 dereferences to. The upstream binary is named `ocr` (the Go
      # package is `cmd/opencodereview`), so the install is renamed to match.
      ocrVersion = "1.12.7";
      ocrFor = pkgs: pkgs.buildGoModule {
        pname = "ocr";
        version = ocrVersion;
        src = pkgs.fetchFromGitHub {
          owner = "alibaba";
          repo = "open-code-review";
          rev = "85cecfe5f935da2b2aae8f91ce4fee8ed343a681";
          hash = "sha256-L1xiiwbgRRZFeVYKwK3Huod97i1lJD12c8EVJGoUW1s=";
        };
        vendorHash = "sha256-f5Ty22wicf1J8+RKnHYcEO7flWn9gkWQODlfunn23EA=";
        subPackages = [ "cmd/opencodereview" ];
        ldflags = [ "-s" "-w" "-X" "main.Version=v${ocrVersion}" "-X" "main.GitCommit=85cecfe" ];
        # Upstream's suite includes e2e tests that talk to a live LLM endpoint and to github.com;
        # nothing in the Nix sandbox can answer them.
        doCheck = false;
        postInstall = "mv $out/bin/opencodereview $out/bin/ocr";
        meta = {
          description = "Open Code Review — an LLM code reviewer that runs against any OpenAI- or Anthropic-compatible endpoint";
          homepage = "https://github.com/alibaba/open-code-review";
          license = lib.licenses.asl20;
          mainProgram = "ocr";
        };
      };

      toolsFor = pkgs:
        let s = scriptsFor pkgs; in
        [ pkgs.gh pkgs.opencode (ocrFor pkgs) s.gh-token s.clip ]
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

      packages = forAll (pkgs: scriptsFor pkgs // { ocr = ocrFor pkgs; });

      devShells = forAll (pkgs: {
        default = pkgs.mkShell ({
          name = "agentic";
          packages = toolsFor pkgs;
          shellHook = ''echo "agentic: gh $(gh --version | head -1 | cut -d' ' -f3) | ocr ${ocrVersion} | $(command -v ai-jail >/dev/null && echo ai-jail || echo 'ai-jail: Linux only') | jail-run claude|opencode|ocr from a directory with .ai-jail"'';
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
