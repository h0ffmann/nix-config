# /etc/nixos/flake.nix
# Final corrected version with Python 3.13 and FHS environment for UV
{
  description = "A comprehensive NixOS flake with development shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable"; # For newer packages if needed

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Correctly defined as a direct URL assignment within the inputs block
    zotero-nix.url = "github:camillemndn/zotero-nix";

    # If you reintroduce python packaging management via these tools, add them back here.
  };

  outputs =
    { self
    , nixpkgs
    , home-manager
    , nixpkgs-unstable # Pass unstable pkgs if needed below
    , zotero-nix
    , ... # ellipsis allows for inputs added/removed without explicit signature change
    }:
    let
      inherit (nixpkgs) lib;
      system = "x86_64-linux";

      # --- PKGS Definition ---
      # Define pkgs with necessary config for the entire flake
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          allowBroken = true; # Use carefully
          permittedInsecurePackages = [
            # Add any needed insecure packages here
          ];
        };
      };

      # Define unstable pkgs if needed for specific dev tools
      pkgsUnstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };

      # --- Python FHS Environment for UV ---
      pythonFHS = pkgs.buildFHSUserEnv {
        name = "py313";
        targetPkgs = pkgs: (with pkgs; [
          # Python and core tools
          python313Full
          python313Packages.pip
          python313Packages.setuptools
          python313Packages.wheel
          python313Packages.virtualenv
          uv
          poetry
          
          # Build essentials for Python packages
          gcc
          glibc
          glibc.dev
          pkg-config
          
          # Common Python dependencies
          zlib
          zlib.dev
          openssl
          openssl.dev
          libffi
          libffi.dev
          readline
          ncurses
          sqlite
          sqlite.dev
          expat
          libxml2
          libxslt
          
          # Git for version control
          git
          git-lfs
          
          # Additional tools that might be needed
          curl
          wget
          which
          file
          binutils
          gnumake
          autoconf
          automake
          libtool
          
          # CA certificates
          cacert
        ]);
        runScript = "bash";
        profile = ''
          export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
          export GIT_SSL_CAINFO=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
          export UV_PYTHON_DOWNLOADS=never
          export PIP_NO_BUILD_ISOLATION=false
        '';
      };

      # --- List of packages for the development environment ---
      packages = with pkgs; [
        # Core Build & System Tools
        xorg.xhost
        bashInteractive
        coreutils
        findutils
        gnugrep
        gnused
        gawk
        gnutar
        gzip
        bzip2
        xz
        which
        file
        gcc
        gnumake
        binutils
        pkg-config
        cacert
        diffutils
        patch

        # --- Version Control ---
        git
        git-lfs

        # --- Shell Utilities & Productivity ---
        ripgrep
        fd
        jq
        yq-go
        just
        tmux
        fzf
        bat
        tree

        # --- Network Tools ---
        curl
        wget
        speedtest-cli
        dig
        bind.dnsutils
        nmap
        lsof
        nghttp2

        # --- Scala Environment ---
        sbt
        scala-cli
        jdk17

        # --- Python Environment (FHS-based) ---
        pythonFHS  # This replaces the normal Python setup
        python313Full  # Keep for system use
        
        # --- Rust Environment ---
        rustc
        cargo
        rust-analyzer # Using Nix-provided toolchain

        # --- WebAssembly Support (for Rust) ---
        wasm-pack
        llvmPackages.lld

        # --- System Libraries ---
        openssl
        openssl.dev
        postgresql
        postgresql.lib
        libclang
        clang
        sqlite
        zlib
        libdrm

        # --- Docker & Container Tools ---
        docker
        docker-compose
        docker-credential-helpers
        hadolint
        steam-run # FHS wrapper

        # --- Supabase Tools ---
        supabase-cli # Assumes supabase-cli is defined elsewhere

        # --- Node.js Environment ---
        nodejs_22
        yarn
        corepack_22
        electron # Nix-provided Electron

        # --- Go Environment ---
        go
        gofumpt
        golangci-lint

        # --- Browser Automation ---
        chromium
        playwright-driver

        # --- GUI & Graphics Libraries ---
        xorg.libX11
        xorg.libXcomposite
        xorg.libXcursor
        xorg.libXdamage
        xorg.libXext
        xorg.libXi
        xorg.libXrandr
        xorg.libXScrnSaver
        xorg.libXtst
        xorg.libxcb
        xorg.libXfixes
        pango
        cairo
        cups.lib
        dbus
        expat
        fontconfig
        freetype
        libpng
        nspr
        nss
        atk
        gdk-pixbuf
        gtk3
        alsa-lib
        glib
        at-spi2-atk
        at-spi2-core
        libxkbcommon
        udev
        mesa
        mesa.drivers
        libGL

        # --- Filesystem Watcher ---
        inotify-tools

        # --- Infrastructure as Code (IaC) & Cloud ---
        terraform
        terraform-ls
        tflint
        terraform-docs
        terragrunt
        pkgsUnstable.pulumi
        google-cloud-sdk
        awscli2

        # --- WaveTerm Integration ---
        # Include appimage-run for running AppImage files
        appimage-run

        # Create wave launcher
        (pkgs.writeShellScriptBin "wave" ''
          #!/usr/bin/env bash
          set -e # Exit on error
          
          WAVE_APPIMAGE="$HOME/Downloads/waveterm-linux-x86_64-0.11.3.AppImage"
          
          if [ ! -f "$WAVE_APPIMAGE" ]; then
            echo "❌ Error: WaveTerm AppImage not found at $WAVE_APPIMAGE"
            echo "   Please download it from: https://github.com/wavetermdev/waveterm/releases/tag/v0.11.3"
            exit 1
          fi
          
          # Make sure the AppImage is executable
          chmod +x "$WAVE_APPIMAGE"
          
          # Change to the home directory which is guaranteed to exist in the container
          cd "$HOME"
          
          echo "🌊 Launching WaveTerm using appimage-run..."
          echo "   Using AppImage: $WAVE_APPIMAGE"
          ${pkgs.appimage-run}/bin/appimage-run "$WAVE_APPIMAGE"
        '')

        # --- Add warp-terminal ---
        warp-terminal
      ];

      # --- Environment Variables for the Shell ---
      env = {
        PUPPETEER_SKIP_CHROMIUM_DOWNLOAD = "1";
        PUPPETEER_SKIP_DOWNLOAD = "1";
        PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
        PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver}/.drivers";
        CARGO_TARGET_WASM32_UNKNOWN_UNKNOWN_LINKER = "${pkgs.llvmPackages.lld}/bin/lld";
        NODE_EXTRA_CA_CERTS = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
        SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
        GIT_SSL_CAINFO = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
      };

      # --- LD_LIBRARY_PATH for GUI/Compatibility ---
      LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
        pkgs.stdenv.cc.cc.lib
        pkgs.xorg.libX11
        pkgs.xorg.libXcomposite
        pkgs.xorg.libXcursor
        pkgs.xorg.libXdamage
        pkgs.xorg.libXext
        pkgs.xorg.libXi
        pkgs.xorg.libXrandr
        pkgs.xorg.libXScrnSaver
        pkgs.xorg.libXtst
        pkgs.xorg.libxcb
        pkgs.xorg.libXfixes
        pkgs.pango
        pkgs.cairo
        pkgs.cups.lib
        pkgs.dbus
        pkgs.expat
        pkgs.fontconfig
        pkgs.freetype
        pkgs.libpng
        pkgs.nspr
        pkgs.nss
        pkgs.atk
        pkgs.gdk-pixbuf
        pkgs.gtk3
        pkgs.alsa-lib
        pkgs.glib
        pkgs.at-spi2-atk
        pkgs.at-spi2-core
        pkgs.libxkbcommon
        pkgs.udev
        pkgs.mesa
        pkgs.libGL
        pkgs.openssl
        pkgs.sqlite
        pkgs.zlib.out
        pkgs.libdrm
      ];

      # --- Shell Hook for Python Env Setup and other init tasks ---
      shellHook = ''
        set -o pipefail
        echo "🔧 Entering Development Environment..."
        if [ -z "$HOME" ]; then echo "❌ CRITICAL: \$HOME not set!"; exit 1; fi
        echo "   User: $USER, Home: $HOME, PWD: $PWD"

        # --- Path Config ---
        echo "--- Configuring PATH ---"
        if [ -d "$HOME/.local/bin" ]; then export PATH="$HOME/.local/bin:$PATH"; fi
        export GOPATH="$PWD/.go"; export GOBIN="$GOPATH/bin"; export PATH="$GOBIN:$PATH"; mkdir -p "$GOPATH" "$GOBIN"
        export NPM_CONFIG_PREFIX="$HOME/.npm-global"; export PATH="$NPM_CONFIG_PREFIX/bin:$PATH"; mkdir -p "$NPM_CONFIG_PREFIX/bin"
        if [ -d "$PWD/scripts" ]; then export PATH="$PWD/scripts:$PATH"; echo "   Added ./scripts to PATH"; fi

        # --- Other Env Setup ---
        mkdir -p "$PWD/.runtime"; export XDG_RUNTIME_DIR="$PWD/.runtime"

        # --- Docker/Podman Status ---
        echo "--- Docker/Podman Status ---"
        if command -v docker &>/dev/null; then 
          if docker info &>/dev/null; then 
            echo "✅ Docker connected."; 
          else 
            echo "⚠️ Docker daemon conn failed."; 
          fi
          alias start-docker='echo "Hint: sudo systemctl start docker.service"'
        elif command -v podman &>/dev/null; then 
          echo "ℹ️ Podman available."; 
          if ! command -v docker &>/dev/null && [ ! -L "$HOME/.local/bin/docker" ]; then 
            mkdir -p "$HOME/.local/bin"; 
            ln -sf "$(which podman)" "$HOME/.local/bin/docker"; 
            echo "   Created Podman alias."; 
          fi
        else 
          echo "⚠️ Docker/Podman not found."; 
        fi

        # --- Python FHS Environment Setup ---
        echo "--- Python 3.13 + UV Setup ---"
        echo "   🐍 Python 3.13 available via FHS environment"
        echo "   📦 To use UV with Python 3.13:"
        echo "      1. Run 'python-dev' to enter FHS environment"
        echo "      2. Inside FHS: 'just setup' will work normally"
        echo "      3. UV will use Python 3.13 without issues"
        echo ""
        echo "   💡 Quick start: python-dev"
        echo ""
        
        if command -v python3 &>/dev/null; then
            echo "   Current Python (outside FHS): $(python3 --version)"
        fi

        # --- Node.js Env Setup ---
        echo "--- Node.js ($(node -v)) Setup ---"
        echo "   npm $(npm -v), yarn $(yarn --version)"
        echo "   Global pkgs: $NPM_CONFIG_PREFIX"
        echo "   NOTE: Prefer local deps/Nix pkgs."
        
        # --- Rust Env Setup ---
        echo "--- Rust ($(rustc --version 2>/dev/null || echo checking...)) Setup ---"
        if command -v rustc &> /dev/null && command -v cargo &> /dev/null; then
            echo "   rustc: $(rustc --version)"
            echo "   cargo: $(cargo --version)"
        else
            echo "   ⚠️ rustc or cargo command not found in Nix environment!"
        fi
        
        # --- Go Env Info ---
        echo "--- Go ($(go version)) Setup ---"; 
        echo "   GOPATH=$GOPATH"
        
        # --- Cloud SDKs Info ---
        echo "--- Cloud SDKs ---"
        if command -v gcloud &>/dev/null; then 
          echo "   GCP SDK available."; 
        else 
          echo "   GCP SDK not found."; 
        fi
        if command -v aws &>/dev/null; then 
          echo "   AWS CLI available."; 
        else 
          echo "   AWS CLI not found."; 
        fi
        
        # --- .env File Loading ---
        echo "--- Checking/Loading .env file ---"
        if [ -f ".env" ]; then 
          echo "   Found .env, loading vars..."
          temp_env_vars=$(mktemp --suffix=-dotenv)
          grep -vE '^\s*(#|$)' .env > "$temp_env_vars" || true
          if [ -s "$temp_env_vars" ]; then 
            processed_lines=0
            skipped_lines=0
            while IFS= read -r line || [ -n "$line" ]; do 
              trimmed_line=$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
              if [[ "$trimmed_line" =~ ^[a-zA-Z_][a-zA-Z0-9_]*=.* ]]; then 
                export "$trimmed_line"
                processed_lines=$((processed_lines + 1))
              elif [ -n "$trimmed_line" ]; then 
                echo "   ⚠️ Skipping invalid line: '$trimmed_line'"
                skipped_lines=$((skipped_lines + 1))
              fi
            done < "$temp_env_vars"
            echo "   ✅ Processed: Loaded $processed_lines vars, skipped $skipped_lines lines."
          else 
            echo "   ℹ️ .env found, but no loadable variable lines."
          fi
          rm "$temp_env_vars"
        else 
          echo "   ⚠️ .env file not found."
          if [ -f ".env.example" ]; then 
            echo "   💡 Hint: Found '.env.example'."
          fi
        fi
        
        # --- Final Message ---
        echo ""
        echo "✨ Development Environment Ready! ✨"
        echo "🐍 For Python 3.13 + UV: run 'python-dev'"
        echo ""
      '';
    in
    {
      # NixOS configuration if it was in the original
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          # Your system configuration modules
          ./configuration.nix
          ./davinci.nix

          # Add home-manager as a module
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.h0ffmann = import ./home.nix;
          }
        ];
      };

      # Define the devShell
      devShells.${system}.default = pkgs.mkShell {
        name = "h0ffmann-devshell";
        inherit packages env LD_LIBRARY_PATH shellHook;
      };

      # System build check
      checks.${system}.build = self.nixosConfigurations.nixos.config.system.build.toplevel;

      # --- Formatter ---
      formatter.${system} = pkgs.nixpkgs-fmt;
    };
}