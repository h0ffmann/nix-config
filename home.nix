{ config, pkgs, ... }:

{
  home.username = "h0ffmann";
  home.homeDirectory = "/home/h0ffmann";
  nixpkgs.config.allowUnfree = true;
  home.packages = with pkgs; [
    # Add your user-specific packages here
    brave
    zoom-us
    xclip
    # warp-terminal
  ];

  programs.bash = {
    enable = true;
    enableCompletion = true;
    # TODO add your custom bashrc here
    bashrcExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
    '';

    # set some aliases, feel free to add more or remove some
    shellAliases = {
      k = "kubectl";
      update = "sudo nixos-rebuild switch"; 
      dumpnix = "sudo cat /etc/nixos/configuration.nix && sudo cat /etc/nixos/home.nix"; 
      urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
      urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
    };
  };
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    extensions = with pkgs.vscode-extensions; [
      # Nix support
      bbenoist.nix
      jnoortheen.nix-ide

      # Just support
      skellock.just

      # Haskell support
      haskell.haskell
      justusadam.language-haskell

      # Scala support
      scala-lang.scala
      scalameta.metals

      # Other useful extensions
      vscodevim.vim  # If you use Vim mode
      ms-python.python  # Python support
      rust-lang.rust-analyzer  # Rust support
      golang.go  # Go support
      eamodio.gitlens  # Git integration
      
      # Theme (optional)
      pkief.material-icon-theme
    ];
    userSettings = {
      "editor.fontFamily" = "Liberation Mono";
      "editor.fontSize" = 14;
      "editor.formatOnSave" = true;
      "files.autoSave" = "onFocusChange";
      "workbench.colorTheme" = "Default Dark+";
      "workbench.iconTheme" = "material-icon-theme";
    };
  };
  programs.git = {
    enable = true;
    userName = "M.Hoffmann";
    userEmail = "hoffmann@poli.ufrj.br";
  };
  dconf.settings = {
    "org/gnome/settings-daemon/plugins/media-keys" = {
      "custom-keybindings" = ["/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      "binding" = "F12";
      "command" = "gnome-terminal";
      "name" = "Open Terminal";
    };
  };

  # starship - an customizable prompt for any shell
  programs.starship = {
    enable = true;
    # custom settings
    settings = {
      add_newline = false;
      aws.disabled = true;
      gcloud.disabled = true;
      line_break.disabled = true;
    };
  };
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;

}
