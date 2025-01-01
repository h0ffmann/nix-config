{ config, pkgs, ... }:

{
  imports = [ ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
  };

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  environment.variables.EDIT = "nano";

  home-manager.users.h0ffmann = import ./home.nix;
  home-manager.backupFileExtension = "backup";

  programs.davinci-resolve-studio.enable = true;
  programs.firefox.enable = true;
  environment.systemPackages = with pkgs; [
    nix-index
    brave
    libGL
    libvdpau
    libva
    tree
    gnome-screenshot
    xorg.libX11
    xorg.libXfixes
    xorg.libXcomposite
    xorg.libXi
    xorg.libXrender
    xorg.libxcb
    xorg.libXScrnSaver
    xorg.libXext
    xorg.libXtst
    # ibus
    # ibus-with-plugins
  ];
  time.timeZone = "America/Sao_Paulo";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "pt_BR.UTF-8";
      LC_IDENTIFICATION = "pt_BR.UTF-8";
      LC_MEASUREMENT = "pt_BR.UTF-8";
      LC_MONETARY = "pt_BR.UTF-8";
      LC_NAME = "pt_BR.UTF-8";
      LC_NUMERIC = "pt_BR.UTF-8";
      LC_PAPER = "pt_BR.UTF-8";
      LC_TELEPHONE = "pt_BR.UTF-8";
      LC_TIME = "pt_BR.UTF-8";
    };
    # inputMethod = {
    #   type = "ibus";
    #   ibus.engines = with pkgs.ibus-engines; [ mozc ];
    # };
  };

  services.dbus.enable = true;

  environment.variables = {
    GTK_IM_MODULE = "ibus";
    QT_IM_MODULE = "ibus";
    XMODIFIERS = "@im=ibus";

  };

  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
    videoDrivers = [ "nvidia" ];
  };

  services.printing.enable = true;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  systemd.user.services.pipewire.serviceConfig = {
    Restart = "always";
    RestartSec = "1";
  };

  systemd.user.services.pipewire-pulse.serviceConfig = {
    Restart = "always";
    RestartSec = "1";
  };


  hardware = {
    pulseaudio.enable = false;
    graphics.enable = true;
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  users.users.h0ffmann = {
    isNormalUser = true;
    description = "h0ffmann";
    extraGroups = [ "networkmanager" "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICB4wkWCip+ackqZ3xc+p0qqXW3Lx+tTuYNTCLXX5pZN hoffmann@poli.ufrj.br"
    ];
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
      PermitRootLogin = "no"; # disable root login
      PasswordAuthentication = false; # disable password login
    };
    openFirewall = true;
  };

  fonts = {
    packages = with pkgs; [
      ipafont
      liberation_ttf
      kochi-substitute
      helvetica-neue-lt-std
      font-awesome
      noto-fonts
      noto-fonts-emoji
      noto-fonts-cjk-sans
    ];
    fontconfig.enable = true;
    enableDefaultPackages = true;
  };
  system.stateVersion = "24.11";
}
