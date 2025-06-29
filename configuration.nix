# /etc/nixos/configuration.nix
{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # --- Bootloader ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # --- Networking ---
  networking = {
    hostName = "nixos"; # You might want to customize this
    networkmanager = {
      enable = true;
      plugins = with pkgs; [
        # Corrected from 'packages'
        networkmanager-openvpn
      ];
    };
    firewall = {
      enable = true;
      allowedUDPPorts = [ 1194 ]; # Example for OpenVPN
      allowedTCPPorts = [ 1194 ]; # Example for OpenVPN
    };
  };

  # --- Nix & Nixpkgs Settings ---
  nixpkgs.config.allowUnfree = true; # Allows installation of non-free packages

  nix = {
    settings = {
      # Enable experimental features (already in your config)
      experimental-features = [ "nix-command" "flakes" ];

      # CPU resource allocation for your i9
      max-jobs = 16; # Use multiple parallel jobs
      cores = 2; # Allocate cores per job

      # Memory and storage optimization
      auto-optimise-store = true;
      use-sqlite-wal = true; # Improve database performance

      # Garbage collection settings suited for large RAM
      min-free = 8589934592; # 8GB in bytes
      max-free = 34359738368; # 32GB in bytes

      # Network download settings
      http-connections = 150; # Allow many concurrent downloads

      # Keep your existing binary caches
      substituters = [
        "https://cache.nixos.org/"
        "https://cuda-maintainers.cachix.org"
        "https://nix-community.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "cuda-maintainers.cachix.org-1:0dqG+swnIlvyuaUg93h2x3/E/RTs2mfH3AMvQ2hAVvg="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    # Add registry settings to pin nixpkgs
    #registry = {
    #  nixpkgs.to = {
    #    type = "path";
    #    path = pkgs.path;
    #    narHash = pkgs.narHash;
    #  };
    #};

    # Configure garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # --- Environment Variables ---
  environment.variables.EDIT = "nano"; # Set default editor

  # --- Home Manager ---
  home-manager.users.h0ffmann = import ./home.nix;
  home-manager.backupFileExtension = "backup";

  # --- Enabled Programs & System Packages ---
  programs.davinci-resolve-studio.enable = true; # Managed via ./davinci.nix
  programs.firefox.enable = true; # Use NixOS module for Firefox

  # Enable Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;    # For Steam Remote Play
    dedicatedServer.openFirewall = true; # For Source Dedicated Server
  };
  
  environment.systemPackages = with pkgs; [
    # Core Tools
    nix-index
    tree
    gnumake
    cmake
    pciutils
    git-lfs
    cachix
    nix-output-monitor # Added for better build visualization

    # Browsers
    brave # Install Brave browser

    # Graphics/Video related (Often pulled as dependencies, check if needed explicitly)
    libGL
    libvdpau # Nvidia related
    libva # Video Acceleration API

    # Desktop Environment (Gnome) & Utilities
    gnome-screenshot
    gnome-session # Correct reference using pkgs
    gnome-settings-daemon # Correct reference using pkgs
    ibus # Input Method Bus

    # Xorg Libs (May be needed by GUI apps, often pulled automatically)
    xorg.libX11
    xorg.libXfixes
    xorg.libXcomposite
    xorg.libXi
    xorg.libXrender
    xorg.libxcb
    xorg.libXScrnSaver
    xorg.libXext
    xorg.libXtst

    # Cloud & Networking Tools
    awscli2
    pritunl-client
    openvpn
    networkmanagerapplet # Optional for Gnome, useful for other DEs
    kubectl
    kubernetes-helm
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

    kooha
    aider-chat
    foliate
    pandoc
    texlive.combined.scheme-medium
    wkhtmltopdf

    bazelisk
    steam-run-free

    gcc
    gnumake
    
    ollama
    nvidia-docker

    # Haskell toolchain
    helix
    stack
    ghc
    cabal-install
    hlint
    haskell-language-server
    ormolu
  ];

  # --- Performance Optimization Settings ---
  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "1048576";
    }
    {
      domain = "*";
      type = "hard";
      item = "nofile";
      value = "1048576";
    }
  ];

  # --- Systemd Services & Targets ---
  systemd.targets.multi-user.wants = [ "pritunl-client.service" ];

  # Note: Manages OpenVPN client based on a specific file path.
  # Consider managing the .ovpn file declaratively if possible for better reproducibility.
  services.openvpn.servers = {
    myVPN = {
      # Make sure this path is correct and accessible by the system service
      config = "config /home/h0ffmann/Downloads/wabee_matheus_wabee-vpn.ovpn.ovpn";
      autoStart = false;
    };
  };

  # --- Locale & Timezone ---
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
      LC_CTYPE = "pt_BR.UTF-8"; # Keep specific CTYPE if needed
    };
  };

  # --- Core System Services ---
  services.dbus.enable = true; # Essential for desktop environments
  services.upower.enable = true; # Power management service
  security.rtkit.enable = true; # Real-time privileges for audio/pipewire

  # --- Console ---
  console = {
    font = "Lat2-Terminus16";
    keyMap = "br-abnt2"; # Set console keymap
  };

  # --- Graphical Session (Xorg + Gnome) ---
  services.xserver = {
    enable = true; # Enable the X server
    displayManager.gdm.enable = true; # Use GDM as the display manager
    desktopManager.gnome.enable = true; # Enable Gnome Desktop Environment
    xkb.layout = "br"; # Set keyboard layout for X session
    xkb.variant = "abnt2"; # Set keyboard variant
    exportConfiguration = true; # Write Xorg config for debugging
    videoDrivers = [ "nvidia" ]; # Use Nvidia proprietary drivers
  };

  # --- Printing ---
  services.printing.enable = true; # Enable CUPS printing service

  # --- Audio (Pipewire) ---
  # Ensure PulseAudio is disabled when using PipeWire's Pulse replacement
  # hardware.pulseaudio.enable = false; # Explicitly disable PulseAudio
  services.pipewire = {
    enable = true; # Enable PipeWire
    alsa.enable = true; # Enable ALSA integration
    alsa.support32Bit = true; # Needed for 32-bit ALSA clients
    pulse.enable = true; # Enable PipeWire's PulseAudio replacement
  };
  # Ensure pipewire services restart if they crash
  systemd.user.services.pipewire.serviceConfig = {
    Restart = "always";
    RestartSec = "1";
  };
  systemd.user.services.pipewire-pulse.serviceConfig = {
    Restart = "always";
    RestartSec = "1";
  };

  # --- Hardware Configuration ---
  hardware = {
    pulseaudio.enable = false; # Ensure pulseaudio is off

    # Graphics Drivers & Support
    graphics = {
      enable = true; # Main toggle for graphics stack (replaces hardware.opengl.enable)
      enable32Bit = true; # Replaces hardware.opengl.driSupport32Bit
    };

    # Nvidia Specific Settings
    nvidia = {
      modesetting.enable = true; # Use kernel modesetting
      # Power management settings; adjust based on hardware/needs
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false; # Use proprietary drivers, not open-source kernel module
      nvidiaSettings = true; # Install the nvidia-settings utility
      # Use the stable driver package corresponding to the kernel
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      # May help with screen tearing on some setups
      forceFullCompositionPipeline = true;
    };

    # Nvidia support for containers (Docker/Podman)
    # Replaces virtualisation.docker.enableNvidia
    nvidia-container-toolkit.enable = true;
  };

  # --- Virtualisation (Docker) ---
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    # Nvidia support handled by hardware.nvidia-container-toolkit.enable
  };

  # --- User Accounts ---
  users.users.h0ffmann = {
    isNormalUser = true;
    description = "h0ffmann";
    # Add user to necessary groups for device/service access
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    # SSH Public Key for login
    openssh.authorizedKeys.keys = [
      # Your public key correctly listed
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICB4wkWCip+ackqZ3xc+p0qqXW3Lx+tTuYNTCLXX5pZN hoffmann@poli.ufrj.br"
    ];
  };

  # --- SSH Server ---
  services.openssh = {
    enable = true; # Enable SSH daemon
    settings = {
      X11Forwarding = true; # Allow X11 forwarding
      PermitRootLogin = "no"; # Disable root login via SSH (good practice)
      PasswordAuthentication = false; # Disable password login (use keys only)
    };
    openFirewall = true; # Open port 22 in the firewall
  };

  # --- Fonts ---
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
    fontconfig.enable = true; # Enable fontconfig configuration
    enableDefaultPackages = true; # Include default font packages
  };

  # --- System State Version ---
  # Helps manage compatibility during NixOS upgrades.
  # Do not change this unless you've reviewed the release notes.
  system.stateVersion = "24.11";

  # --- Experimental Gnome Settings ---
  # Note: Using extraGSettingsOverridePackages might be fragile.
  # Prefer managing settings via home-manager or dedicated options if possible.
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
}
