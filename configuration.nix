{ config, pkgs, lib, ... }:

{
  imports = [ 
	./hardware-configuration.nix
        # <home-manager/nixos> 
  ];

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


  programs.firefox.enable = true;
  environment.systemPackages = with pkgs; [
    brave
    libGL
    libvdpau
    libva
    xorg.libX11
    xorg.libXfixes
    xorg.libXcomposite
    xorg.libXi
    xorg.libXrender
    xorg.libxcb
    xorg.libXScrnSaver
    xorg.libXext
    xorg.libXtst
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
  };

  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
    videoDrivers = ["nvidia"];
  };

  services.printing.enable = true;
  security.rtkit.enable = true;
  
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  hardware = {
    pulseaudio.enable = false;
    graphics.enable = true;
    # opengl.enable = true;
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
  };

  fonts = {
    packages = with pkgs; [
      liberation_ttf
      helvetica-neue-lt-std
      font-awesome
      noto-fonts
      noto-fonts-emoji
    ];
    fontconfig.enable = true;
    enableDefaultFonts = true;
  };  
  system.stateVersion = "24.11";
}
