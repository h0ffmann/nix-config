{ config, pkgs, ... }:

{
  home.username = "h0ffmann";
  home.homeDirectory = "/home/h0ffmann";
  nixpkgs.config.allowUnfree = true;
  home.packages = with pkgs; [
    brave
    zoom-us
    xclip
    nil # Add this line - Nix Language Server
    nixpkgs-fmt # Add this for formatting
    statix # Nix Linting
    obsidian
    yt-dlp
    just
    protonvpn-cli
    cabal-install
    ghc
  ];

  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
      export DCODE=$HOME/Code
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
    '';

    # set some aliases, feel free to add more or remove some
    shellAliases = {
      k = "kubectl";
      nixedit = "cd /etc/nixos && code .";
      devshell = "nix develop --impure -f /etc/nixos/dev-shell.nix";
      devedit = "code /etc/nixos/dev-shell.nix";
      urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
      urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
    };
  };

  programs.git = {
    enable = true;
    lfs = {
      enable = true;
    };
    userName = "M.Hoffmann";
    userEmail = "hoffmann@poli.ufrj.br";
  };

  dconf.settings = {
    "org/gnome/settings-daemon/plugins/media-keys" = {
      "custom-keybindings" = [ "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/" ];
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
