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

        # Scala support
        scalameta.metals
        scala-lang.scala
      ];
      userSettings = {
        "vim.enabled" = false;
        "keyboard.dispatch" = "keyCode";
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
        # Metals/Scala settings
        "metals.enable" = true;
        "metals.scalafmtVersion" = "3.7.17";

        # Configure Metals to use Scala 3
        "metals.serverProperties" = [
          "-Xss4m"
          "-Xms100m"
          "-Xmx2g"
        ];
        "metals.scalacOptions" = [
          "-Xfatal-warnings"
          "-deprecation"
          "-feature"
        ];

        # Metals Scala Syntax cfg
        "metals.showInferredType" = true; # Shows inferred types during hover
        "metals.showImplicitArguments" = true; # Shows implicit parameter hints
        "metals.showImplicitConversionsAndClasses" = true; # Shows implicit conversions
        "metals.enableSemanticHighlighting" = true; # Better syntax highlighting

        # Update Metals settings to use Nix-packaged version
        "metals.javaHome" = "${pkgs.jdk17}/lib/openjdk";
        "metals.serverVersion" = "1.2.0";
        "metals.sbtScript" = "${pkgs.sbt}/bin/sbt";
        "metals.bloopVersion" = "1.5.13";

        # Add this to ensure Metals uses the correct Coursier
        "metals.customRepositories" = [ ];
        "metals.bloopSbtLocation" = "${pkgs.bloop}/bin/bloop";

        # File type associations
        "[scala]" = {
          "editor.defaultFormatter" = "scalameta.metals";
          "editor.formatOnSave" = true;
        };
      };
    };
  };
}
