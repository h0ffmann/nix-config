{
  description = "prático — a local pilot for zsh: zsh-ai → llm → Ollama (Qwen coder), with ai-jail for sandboxed agents";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    zsh-ai = {
      url = "github:thiswillbeyourgithub/zsh-ai"; # default branch is `fork`; carries zsh-ai.zsh
      flake = false; # plain source; hash pinned in flake.lock
    };
    # ai-jail — sandboxes AI coding agents (Claude Code, OpenCode, ...) behind
    # bubblewrap/Landlock/seccomp on Linux. See `just jail-*` and `.ai-jail`.
    ai-jail = {
      url = "github:akitaonrails/ai-jail";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, zsh-ai, ai-jail, ... }:
    let
      inherit (nixpkgs) lib;
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      forAll = f: lib.genAttrs systems (s: f nixpkgs.legacyPackages.${s});
      model = "qwen2.5-coder:7b"; # ollama pull qwen2.5-coder:7b  (once)
    in
    {
      devShells = forAll (pkgs:
        let
          inherit (pkgs.stdenv.hostPlatform) system;
          isLinux = pkgs.stdenv.hostPlatform.isLinux;
          # ai-jail's test suite needs a working sandbox at build time, which the
          # Nix build sandbox does not provide — same override marola uses.
          aiJail = ai-jail.packages.${system}.default.overrideAttrs (_: { doCheck = false; });
        in
        rec {
          pratico = pkgs.mkShell ({
            name = "pratico";

            packages = [
              (pkgs.python3.withPackages (ps: [ ps.llm ps.llm-ollama ]))
              pkgs.zsh
              pkgs.curl
              pkgs.fzf # zsh-ai picks a suggestion through fzf
              pkgs.just # `just jail-claude`, `just pull`, ...
            ] ++ lib.optionals isLinux [
              aiJail # bubblewrap/Landlock/seccomp — Linux only
              pkgs.bubblewrap
            ];

            LLM_MODEL = model; # default model for `llm`
            ZSH_AI_LLM_NAME = model; # zsh-ai's own model variable (defaults to o4-mini otherwise)
            OLLAMA_HOST = "http://127.0.0.1:11434"; # host's ollama.service

            shellHook = ''
              if ! curl -sf "$OLLAMA_HOST/api/tags" >/dev/null 2>&1; then
                echo "prático: Ollama not reachable at $OLLAMA_HOST — run 'just ollama-serve' or check systemd" >&2
              elif ! curl -sf "$OLLAMA_HOST/api/tags" | grep -q '"${model}"'; then
                echo "prático: model ${model} not found — run: just pull" >&2
              fi

              # Your real ~/.zshrc loads the plugin when this var is set:
              #   [[ -n "$ZSH_AI_PLUGIN" ]] && source "$ZSH_AI_PLUGIN"
              export ZSH_AI_PLUGIN=${zsh-ai}/zsh-ai.zsh

              # Re-exec into zsh once (nix develop starts in bash).
              if [ -z "$IN_PRATICO" ]; then
                export IN_PRATICO=1
                exec zsh
              fi
            '';
          } // lib.optionalAttrs isLinux {
            # ai-jail's own flake sets this in its devShell; it does not propagate when
            # consumed as a package input, so point it at bwrap explicitly.
            BWRAP_BIN = "${pkgs.bubblewrap}/bin/bwrap";
          });

          default = pratico;
        });
    };
}
