# /etc/nixos/configuration.nix
{ config, pkgs, lib, ... }: # Added lib for optional settings like mkDefault

{
  imports = [ ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.gvfs.enable = true;

  networking = {
    hostName = "nixos";
    networkmanager = {
      enable = true;
      packages = with pkgs; [
        networkmanager-openvpn
      ];
    };
    firewall = {
      enable = true;
      allowedUDPPorts = [ 1194 ]; # Default OpenVPN port
      allowedTCPPorts = [ 1194 ];
    };
  };

  # Enable Docker
  virtualisation.docker = {
    enable = true;
    # Optional: enable rootless mode
    # rootless = {
    #   enable = true;
    #   setSocketVariable = true;
    # };
  };

  # --- Nix Settings ---
  nixpkgs.config.allowUnfree = true; # Keep this

  nix.settings = {
    # --- Binary Cache Configuration (Added for Cachix) ---
    substituters = [
      "https://cache.nixos.org/" # Default NixOS cache (keep first)
      "https://cuda-maintainers.cachix.org" # Essential for CUDA packages
      "https://nix-community.cachix.org" # General community cache
      # Add other caches if needed, one per line
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" # Key for cache.nixos.org
      "cuda-maintainers.cachix.org-1:0dqG+swnIlvyuaUg93h2x3/E/RTs2mfH3AMvQ2hAVvg=" # Key for cuda-maintainers
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" # Key for nix-community
      # Add keys corresponding to other caches if you add them
    ];

    # --- Existing Experimental Features ---
    experimental-features = [ "nix-command" "flakes" ];

    # --- Optional Performance Tweaks (Uncomment and adjust if desired) ---
    # max-jobs = lib.mkDefault 8; # Adjust based on your CPU cores/RAM
    # cores = lib.mkDefault 4;    # Adjust based on your CPU
  };
  # --- End Nix Settings ---

  environment.variables.EDIT = "nano";

  # Assuming ./home.nix exists in /etc/nixos/
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
    gnome-session
    gnome-settings-daemon
    xorg.libX11
    xorg.libXfixes
    xorg.libXcomposite
    xorg.libXi
    xorg.libXrender
    xorg.libxcb
    xorg.libXScrnSaver
    xorg.libXext
    xorg.libXtst
    pciutils
    ibus
    # gnome.gnome-session # Already enabled via desktopManager.gnome
    # gnome.gnome-settings-daemon # Already enabled via desktopManager.gnome
    gnumake
    cmake
    awscli2
    pritunl-client
    openvpn
    networkmanagerapplet
    kubectl
    kubernetes-helm
    git-lfs
    lens
    kubeseal
    gettext
    vault
    metals
    jdk17
    sbt
    bloop
    scala
    jetbrains.idea-community
    nodejs # Consider managing Node via home-manager or flakes for specific versions
    jq
    yq
    istioctl
    dbeaver-bin
    cachix # Keep cachix tool installed if you use its CLI commands
    gh
  ];

  systemd.targets.multi-user.wants = [ "pritunl-client.service" ];
  services.openvpn.servers = {
    myVPN = {
      # Make sure this path is correct and accessible by the system service
      config = "config /home/h0ffmann/Downloads/wabee_matheus_wabee-vpn.ovpn.ovpn";
      autoStart = false; # Set to true if you want it to start automatically
    };
  };

  time.timeZone = "America/Sao_Paulo";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
      LC_CTYPE = "pt_BR.UTF-8"; # Keeping pt_BR for CTYPE as per original
    };
  };

  services.dbus.enable = true;
  services.upower.enable = true;

  console = {
    font = "Lat2-Terminus16";
    keyMap = "br-abnt2";
  };

  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    xkb.layout = "br";
    xkb.variant = "abnt2";
    exportConfiguration = true;
    videoDrivers = [ "nvidia" ]; # Correctly identifies NVIDIA driver need
  };

  services.printing.enable = true;
  security.rtkit.enable = true; # Good for PipeWire

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # You likely don't need these Restart settings unless specifically troubleshooting PipeWire issues
  # systemd.user.services.pipewire.serviceConfig = {
  #   Restart = "always";
  #   RestartSec = "1";
  # };
  # systemd.user.services.pipewire-pulse.serviceConfig = {
  #   Restart = "always";
  #   RestartSec = "1";
  # };

  hardware = {
    pulseaudio.enable = false; # Correctly disabled for PipeWire
    graphics.enable = true; # Enables Mesa drivers, generally safe alongside NVIDIA
    nvidia = {
      modesetting.enable = true; # Good for modern setups/Wayland
      powerManagement.enable = false; # Explicitly disabled
      powerManagement.finegrained = false; # Explicitly disabled
      open = false; # Use proprietary driver
      nvidiaSettings = true; # Install nvidia-settings tool
      # Uses the stable NVIDIA package appropriate for your kernel
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      # Optional: helps with tearing on X11, might not be needed/wanted on Wayland
      forceFullCompositionPipeline = true;
    };
  };

  users.users.h0ffmann = {
    isNormalUser = true;
    description = "h0ffmann";
    extraGroups = [ "networkmanager" "wheel" "storage" "plugdev" "docker" ]; # wheel for sudo, docker for docker group
    openssh.authorizedKeys.keys = [
      # Your public key correctly listed
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICB4wkWCip+ackqZ3xc+p0qqXW3Lx+tTuYNTCLXX5pZN hoffmann@poli.ufrj.br"
    ];
  };

  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
    openFirewall = true; # Allows SSH connections through the firewall
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

  system.stateVersion = "24.11"; # Change this when you intentionally make breaking changes

  # --- Experimental Gnome Settings ---
  services.xserver.desktopManager.gnome.extraGSettingsOverridePackages = [ pkgs.gnome-settings-daemon ];

  services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.desktop.screensaver]
      lock-delay=3600
      lock-enabled=true
    [org.gnome.desktop.session]
      idle-delay=3600
    [org.gnome.settings-daemon.plugins.power]
      power-button-action='nothing'
      idle-dim=true
      sleep-inactive-battery-type='nothing'
      sleep-inactive-ac-timeout=3600
      sleep-inactive-ac-type='nothing'
      sleep-inactive-battery-timeout=3600
  '';
  # --- End Experimental Gnome Settings ---


  # --- Nix-ld Settings ---
  # Enable nix-ld for running non-Nix binaries
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Add libraries required by dynamically linked binaries you run outside Nix environments
    stdenv.cc.cc.lib # Basic C++ standard library
    libGL # Example: If running binaries needing OpenGL
    # Add more libs as needed, e.g., zlib, openssl etc.
  ];
  # --- End Nix-ld Settings ---

}
