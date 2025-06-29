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

        # Haskell Extensions - Full Suite
        haskell.haskell                    # Main Haskell extension with HLS
        justusadam.language-haskell        # Additional syntax support
        # Note: You may also want to add these via extensions.fromMarketplace if not available in nixpkgs:
        # - phoityne.phoityne-vscode       # Haskell debugger
        # - vigoo.stylish-haskell          # Code formatter
        # - alanz.vscode-hie-server        # Alternative HLS support (if needed)

        # Scala support
        scalameta.metals
        scala-lang.scala

        # Additional useful extensions for Haskell development
        ms-vscode.vscode-json              # JSON support (for cabal.project.local, etc.)
        redhat.vscode-yaml                 # YAML support (for stack.yaml, etc.)
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

        # Haskell Language Server (HLS) Configuration
        "haskell.manageHLS" = "PATH";  # Use HLS from system PATH (Nix-provided)
        "haskell.serverEnvironment" = {
          "PATH" = "${pkgs.haskell-language-server}/bin:${pkgs.ghc}/bin:${pkgs.cabal-install}/bin:${pkgs.stack}/bin:$PATH";
        };
        
        # HLS specific settings
        "haskell.plugin.importLens.codeActionsOn" = true;
        "haskell.plugin.importLens.codeLensOn" = true;
        "haskell.plugin.hlint.codeActionsOn" = true;
        "haskell.plugin.hlint.diagnosticsOn" = true;
        "haskell.plugin.eval.codeActionsOn" = true;
        "haskell.plugin.eval.codeLensOn" = true;
        "haskell.plugin.moduleName.codeActionsOn" = true;
        "haskell.plugin.retrie.codeActionsOn" = true;
        "haskell.plugin.tactics.codeActionsOn" = true;
        "haskell.plugin.tactics.codeLensOn" = true;
        "haskell.plugin.pragmas.codeActionsOn" = true;
        "haskell.plugin.pragmas.codeLensOn" = true;
        "haskell.plugin.gadt.codeActionsOn" = true;
        "haskell.plugin.qualifyImportedNames.codeActionsOn" = true;
        "haskell.plugin.refineImports.codeActionsOn" = true;
        "haskell.plugin.rename.codeActionsOn" = true;
        "haskell.plugin.splice.codeActionsOn" = true;
        "haskell.plugin.floskell.codeActionsOn" = true;
        "haskell.plugin.fourmolu.codeActionsOn" = true;
        "haskell.plugin.ormolu.codeActionsOn" = true;
        "haskell.plugin.stylishHaskell.codeActionsOn" = true;
        "haskell.plugin.brittany.codeActionsOn" = true;

        # Haskell formatting settings
        "haskell.formattingProvider" = "ormolu";  # Options: "brittany", "floskell", "fourmolu", "ormolu", "stylish-haskell"
        
        # Code completion settings
        "haskell.completionSnippetsOn" = true;
        "haskell.maxCompletions" = 40;
        
        # Trace settings for debugging HLS issues
        "haskell.trace.server" = "messages";  # Options: "off", "messages", "verbose"
        "haskell.logFile" = "";  # Set to a file path if you want detailed logs
        
        # Performance settings
        "haskell.openDocumentTimeout" = 60;
        "haskell.openSourceFileTimeout" = 60;

        # File associations for Haskell
        "[haskell]" = {
          "editor.defaultFormatter" = "haskell.haskell";
          "editor.formatOnSave" = true;
          "editor.insertSpaces" = true;
          "editor.tabSize" = 2;
          "editor.detectIndentation" = false;
          "editor.wordWrap" = "on";
          "editor.rulers" = [ 80 100 ];
        };
        "[cabal]" = {
          "editor.insertSpaces" = true;
          "editor.tabSize" = 2;
        };
        "[yaml]" = {
          "editor.insertSpaces" = true;
          "editor.tabSize" = 2;
        };

        # Files associations
        "files.associations" = {
          "*.hs" = "haskell";
          "*.lhs" = "haskell";
          "*.hsc" = "haskell";
          "*.cabal" = "cabal";
          "cabal.project" = "cabal";
          "cabal.project.local" = "cabal";
          "stack.yaml" = "yaml";
          "stack.yaml.lock" = "yaml";
          "package.yaml" = "yaml";
        };

        # Search and exclude settings for Haskell projects
        "search.exclude" = {
          "**/.stack-work" = true;
          "**/dist" = true;
          "**/dist-newstyle" = true;
          "**/.cabal-sandbox" = true;
        };
        
        "files.exclude" = {
          "**/.stack-work" = true;
          "**/dist" = true;
          "**/dist-newstyle" = true;
          "**/.cabal-sandbox" = true;
        };

        "files.watcherExclude" = {
          "**/.stack-work/**" = true;
          "**/dist/**" = true;
          "**/dist-newstyle/**" = true;
          "**/.cabal-sandbox/**" = true;
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