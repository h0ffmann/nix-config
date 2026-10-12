{ config, pkgs, ... }:

{
  home.username = "h0ffmann";
  home.homeDirectory = "/home/h0ffmann";
  home.packages = with pkgs; [
    vscode
    zoom-us
    xclip
    nil # Add this line - Nix Language Server
    nixpkgs-fmt # Add this for formatting
    statix # Nix Linting
    obsidian
    yt-dlp
    just
    proton-vpn-cli
  ];

  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
      export DCODE=$HOME/Code
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
      # Check if running in WaveTerm
      if [[ "$TERM_PROGRAM" == "WaveTerm" ]]; then
        # Use a simple prompt without fancy formatting
        export PS1="[\u@\h \W]$ "
      fi
    '';

    # set some aliases, feel free to add more or remove some
    shellAliases = {
      k = "kubectl";
      nixedit = "cd /etc/nixos && code .";
      devshell = "nix develop /etc/nixos# --impure";
      devedit = "code /etc/nixos/flake.nix";
      urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
      urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
    };
  };

  programs.git = {
    enable = true;
    lfs = {
      enable = true;
    };
    settings.user = {
      name = "M.Hoffmann";
      email = "hoffmann@poli.ufrj.br";
    };
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
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;

}
