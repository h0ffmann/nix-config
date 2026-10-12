# /etc/nixos/configuration.nix
{ config, lib, pkgs, graphify, pins, ... }:

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
        "https://nix-community.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
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
    remotePlay.openFirewall = true; # For Steam Remote Play
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
    libx11
    libxfixes
    libxcomposite
    libxi
    libxrender
    libxcb
    libxscrnsaver
    libxext
    libxtst

    # Cloud & Networking Tools
    awscli2
    pritunl-client
    openvpn
    networkmanagerapplet # Optional for Gnome, useful for other DEs
    kubectl
    kubernetes-helm
    kubeseal
    gettext
    vault
    nodejs # Consider managing Node via home-manager or flakes for specific versions
    jq
    yq
    istioctl
    cachix # Keep cachix tool installed if you use its CLI commands
    gh
    claude-code
    graphify

    kooha
    foliate
    pandoc

    bazelisk
    steam-run-free

    gcc
    gnumake

    ollama
    nvidia-docker

    helix
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
    xkb.layout = "br"; # Set keyboard layout for X session
    xkb.variant = "abnt2"; # Set keyboard variant
    exportConfiguration = true; # Write Xorg config for debugging
    videoDrivers = [ "nvidia" ]; # Use Nvidia proprietary drivers
  };

  services.displayManager.gdm.enable = true; # Use GDM as the display manager
  services.desktopManager.gnome.enable = true; # Enable Gnome Desktop Environment

  # --- Printing ---
  services.printing.enable = true; # Enable CUPS printing service

  # --- Audio (Pipewire) ---
  # Ensure PulseAudio is disabled when using PipeWire's Pulse replacement
  services.pulseaudio.enable = false; # Ensure pulseaudio is off
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
      noto-fonts-color-emoji
      noto-fonts-cjk-sans
    ];
    fontconfig.enable = true; # Enable fontconfig configuration
    enableDefaultPackages = true; # Include default font packages
  };

  # --- VM for trying this config from another OS ---
  # Only `nixos-rebuild build-vm` / `.#nixosConfigurations.nixos.config.system.build.vm`
  # reads this; the installed system ignores it. The NVIDIA driver cannot drive a QEMU
  # display, and the config sets no user password, so without these the VM boots to a
  # black screen or a login nobody can pass.
  #
  # `just vm` shares the host's checkout, ~/.claude and ~/repos, and hands over `gh auth token`
  # through fw_cfg so it never lands in a file or in qemu's argv. Without the variables the shares
  # fall back to the empty xchg dir and the plain run-nixos-vm still boots. 9p "none" keeps host
  # ownership, so the guest uid must match the host's (1000 for Ubuntu's first user).
  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 8192;
      cores = 4;
      diskSize = 20480;
      # store writes (nix develop, nix build inside the VM) go to the disk image, not to RAM
      writableStoreUseTmpfs = false;
      sharedDirectories = {
        nix-config = {
          source = ''"''${VM_NIX_CONFIG:-$TMPDIR/xchg}"'';
          target = "/mnt/nix-config";
          securityModel = "none";
        };
        claude = {
          source = ''"''${VM_CLAUDE_DIR:-$TMPDIR/xchg}"'';
          target = "/mnt/claude";
          securityModel = "none";
        };
        repos = {
          source = ''"''${VM_REPOS:-$TMPDIR/xchg}"'';
          target = "/mnt/repos";
          securityModel = "none";
        };
      };
    };
    users.users.h0ffmann = {
      initialPassword = "nixos";
      uid = 1000;
    };
    users.motd = with pkgs; ''

        nix-config VM  ·  NixOS ${lib.versions.majorMinor lib.version}
        ──────────────────────────────────────────────────────────────────
        pinned in flake.lock
      ${lib.concatMapStrings (l: "    ${l}\n") pins}
        linux ${config.boot.kernelPackages.kernel.version} · nix ${config.nix.package.version} · claude-code ${claude-code.version} · gh ${gh.version} · graphify ${(builtins.parseDrvName graphify.name).version}

        login h0ffmann / nixos · ~/nix-config, ~/.claude and ~/repos come from the host
        just freeze vm      every package in the VM, name==version
        just vm-uninstall   delete the disk and every store path only the VM uses
    '';
    services.xserver.videoDrivers = lib.mkForce [ "modesetting" ];
    hardware.nvidia-container-toolkit.enable = lib.mkForce false;
    boot.kernelModules = [ "qemu_fw_cfg" ];
    environment.extraInit = ''
      if [ -r /run/gh-token ]; then export GH_TOKEN="$(cat /run/gh-token)"; fi
    '';
    # ww3-gpu's submodules use git@ URLs and the VM has no SSH key; gh's token covers https.
    programs = {
      davinci-resolve-studio.enable = lib.mkForce false;
      git = {
        enable = true;
        config = {
          url."https://github.com/".insteadOf = "git@github.com:";
          credential."https://github.com".helper = "!${pkgs.gh}/bin/gh auth git-credential";
        };
      };
    };
    systemd = {
      tmpfiles.rules = [
        "L+ /home/h0ffmann/nix-config - - - - /mnt/nix-config"
        "L+ /home/h0ffmann/.claude - - - - /mnt/claude"
        "L+ /home/h0ffmann/repos - - - - /mnt/repos"
      ];
      services.host-gh-token = {
        wantedBy = [ "multi-user.target" ];
        after = [ "systemd-modules-load.service" ];
        serviceConfig.Type = "oneshot";
        script = ''
          f=/sys/firmware/qemu_fw_cfg/by_name/opt/gh-token/raw
          [ -r "$f" ] || exit 0
          umask 077
          cat "$f" > /run/gh-token
          chown h0ffmann /run/gh-token
        '';
      };
      # Clones live on the host (~/repos by default), so they survive `just vm-reset`; a repo that
      # is already there is never cloned again. The marker keeps a plain run-nixos-vm, whose share
      # is a throwaway temp dir, from cloning at all. nagori is private: it clones only with gh's
      # token, which proves the hand-over works. Karpathy's main repos are there to read and run.
      services.vm-repos = {
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" "host-gh-token.service" ];
        unitConfig.ConditionPathExists = "/mnt/repos/.vm-repos";
        path = [ pkgs.git ];
        environment.HOME = "/home/h0ffmann";
        serviceConfig = {
          Type = "oneshot";
          User = "h0ffmann";
        };
        script = ''
          if [ -r /run/gh-token ]; then GH_TOKEN="$(cat /run/gh-token)"; export GH_TOKEN; fi
          for r in marola-dev/marola marola-dev/marola-devkit h0ffmann/ww3-gpu h0ffmann/nagori \
            karpathy/nanochat karpathy/nanoGPT karpathy/llm.c karpathy/llama2.c karpathy/minbpe karpathy/micrograd; do
            d=/mnt/repos/''${r#*/}
            if [ -e "$d/.git" ]; then
              git -C "$d" submodule update --init --recursive || true
            else
              git clone --recurse-submodules "https://github.com/$r" "$d" || echo "vm-repos: $r failed; retried next boot"
            fi
          done
        '';
      };
    };
  };

  # --- System State Version ---
  # Helps manage compatibility during NixOS upgrades.
  # Do not change this unless you've reviewed the release notes.
  system.stateVersion = "26.05";

  # --- Experimental Gnome Settings ---
  # Note: Using extraGSettingsOverridePackages might be fragile.
  # Prefer managing settings via home-manager or dedicated options if possible.
  services.desktopManager.gnome.extraGSettingsOverridePackages = [ pkgs.gnome-settings-daemon ];
  services.desktopManager.gnome.extraGSettingsOverrides = ''
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
