{ pkgs, ... }: {
  # Add home-manager prefix
  home-manager.users.h0ffmann = {
    programs.vscode = {
      enable = true;
      package = pkgs.vscode;
      extensions = with pkgs.vscode-extensions; [
        # Nix support
        bbenoist.nix
        jnoortheen.nix-ide

        # Add Just support
        skellock.just

        # Theme
        pkief.material-icon-theme

        # Haskell
        justusadam.language-haskell
        haskell.haskell
      ];
      userSettings = {
        "vim.enabled" = false;
        "editor.defaultKeybindingEnabled" = true;
        "editor.fontFamily" = "Liberation Mono";
        "editor.fontSize" = 14;
        "editor.formatOnSave" = true;
        "files.autoSave" = "onFocusChange";
        "workbench.colorTheme" = "Default Dark+";
        "workbench.iconTheme" = "material-icon-theme";

        # Nix settings
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nil";
        "nix.serverSettings" = {
          "nil" = {
            "formatting" = {
              "command" = [ "nixpkgs-fmt" ];
            };
          };
        };
        "[nix]" = {
          "editor.defaultFormatter" = "jnoortheen.nix-ide";
          "editor.formatOnSave" = true;
        };
      };
    };
  };
}
