<<<<<<< HEAD
# /etc/nixos/flake.nix
# Final corrected version incorporating fixes
{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable"; # For newer packages if needed
=======
# flake.nix (modified part)
{
  description = "A simple NixOS flake";

  # --- Inputs section remains the same ---
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable"; # Keep if needed for specific packages
>>>>>>> cadbe02 (Convert legacy dev-shell to flake devShells.default)

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

<<<<<<< HEAD
    # Correctly defined as a direct URL assignment within the inputs block
    zotero-nix.url = "github:camillemndn/zotero-nix";

    # Removed pyproject-nix, uv2nix, etc. as they were removed by `flake update`
    # and not currently used in the system configuration or default dev shell.
    # If you reintroduce python packaging management via these tools, add them back here.
  };

=======
    # ... other inputs ...
  };

  # inputs.zotero-nix.url = ... # Keep

>>>>>>> cadbe02 (Convert legacy dev-shell to flake devShells.default)
  outputs =
    { self
    , nixpkgs
    , home-manager
<<<<<<< HEAD
    , nixpkgs-unstable # Pass unstable pkgs if needed below
    , zotero-nix
    , ... # ellipsis allows for inputs added/removed without explicit signature change
=======
    , nixpkgs-unstable # Make unstable available if needed
    , zotero-nix
    # ... other inputs ...
    , ...
>>>>>>> cadbe02 (Convert legacy dev-shell to flake devShells.default)
    }:
    let
      inherit (nixpkgs) lib;
      system = "x86_64-linux";

      # --- PKGS Definition ---
<<<<<<< HEAD
      # Define pkgs with necessary config for the entire flake
=======
      # Define pkgs with necessary overlays/config for the entire flake
>>>>>>> cadbe02 (Convert legacy dev-shell to flake devShells.default)
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
<<<<<<< HEAD
          allowBroken = true; # Use carefully
          permittedInsecurePackages = [
            # Add any needed insecure packages here
          ];
        };
      };

      # Define unstable pkgs if specific newer versions are required
      pkgsUnstable = import nixpkgs-unstable {
        inherit system;
        config = {
          allowUnfree = true; # Allow unfree from unstable if necessary
        };
      };

    in
    {
      # --- NixOS System Configuration ---
      # Fixed structure using nixpkgs.lib.nixosSystem
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        # The 'modules' attribute that was previously missing/malformed
        modules = [
          # Use an anonymous module to import configuration files
          {
            imports = [
              ./configuration.nix
              ./hardware-configuration.nix
              ./vscode.nix # Your custom vscode module
              ./davinci.nix # Your custom davinci resolve module
            ];

            # You can add system-wide packages directly here too
            # Or keep them in configuration.nix as before
            environment.systemPackages = [
              # Make zotero package available system-wide
              # Ensures zotero-nix input is passed correctly to outputs
              zotero-nix.packages.${system}.default
              pkgs.calibre # Example of adding another package
            ];
          }

          # Integrate Home Manager at the system level
          home-manager.nixosModules.home-manager
        ];

        # Optional: If your modules need access to flake inputs
        # specialArgs = { inherit inputs pkgs pkgsUnstable; };
      };

      # --- Development Shell (converted from dev-shell.nix) ---
      devShells."${system}".default = pkgs.mkShell {
        name = "dev";

        # --- List of packages for the development environment ---
        packages = with pkgs; [
          # Core Build & System Tools
          pkgs.xorg.xhost
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
          # Version Control
          git
          git-lfs
          # Shell Utilities & Productivity
          ripgrep
          fd
          jq
          yq-go
          just
          tmux
          fzf
          bat
          tree
          # Network Tools
          curl
          wget
          speedtest-cli
          dig
          bind.dnsutils
          nmap
          lsof
          nghttp2
          # Scala Environment
          sbt
          scala-cli
          jdk17
          # Python Environment
          python312
          uv
          poetry
          (python312.withPackages (ps: with ps; [ pip setuptools wheel virtualenv conda ])) # Base tools
          # Rust Environment
          rustc
          cargo
          rust-analyzer # Nix-provided toolchain
          # WebAssembly Support
          wasm-pack
          llvmPackages.lld
          # System Libraries
          openssl
          openssl.dev
          postgresql
          postgresql.lib
          libclang
          clang
          sqlite
          zlib
          libdrm
          # Docker & Container Tools
          docker
          docker-compose
          docker-credential-helpers
          hadolint
          steam-run # FHS wrapper
          # Node.js Environment
          nodejs_22
          yarn
          corepack_22
          electron # Nix-provided Electron
          # Go Environment
          go
          gofumpt
          golangci-lint
          # Browser Automation
          chromium
          playwright-driver
          # GUI & Graphics Libraries
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
          # Filesystem Watcher
          inotify-tools
          # Infrastructure as Code (IaC) & Cloud
          terraform
          terraform-ls
          tflint
          terraform-docs
          terragrunt
          google-cloud-sdk
          awscli2
          pkgsUnstable.pulumi
          minikube
          pandoc
        ];

        # --- Environment Variables for the Shell ---
=======
          allowBroken = true; # As per your dev-shell.nix; use carefully
          permittedInsecurePackages = [
             # List any required insecure packages here, matching dev-shell.nix
             # e.g., "openssl-1.1.1"
          ];
          # Include overlays if necessary, like for pythonSet later
        };
      };
      # Define unstable pkgs if needed for specific dev tools
      pkgsUnstable = import nixpkgs-unstable {
         inherit system;
         config.allowUnfree = true; # If unstable packages need it
      };

      # --- Python setup remains similar, but ensure it uses the flake's pkgs ---
      # workspace = ...
      # overlay = ...
      # pyprojectOverrides = ...
      # python = pkgs.python312;
      # pythonSet = ...


    in
    {
      # --- nixosConfigurations.nixos remains the same ---
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
         # ... existing configuration ...
      };

      # --- Existing packages.x86_64-linux.default might need review ---
      # packages.x86_64-linux.default = ...

      # --- Define the NEW devShell ---
      devShells."${system}".default = pkgs.mkShell {
        # Use the name from dev-shell.nix if desired, mainly for prompts
        name = "h0ffmann-devshell-flake";

        # --- Copy 'packages' directly from dev-shell.nix ---
        # Use 'pkgs.' prefix. Use pkgsUnstable for specific newer versions if needed.
        packages = with pkgs; [
          # --- Core Build & System Tools ---
          bashInteractive coreutils findutils gnugrep gnused gawk gnutar gzip bzip2 xz which file gcc gnumake binutils pkg-config cacert diffutils patch
          # --- Version Control ---
          git git-lfs
          # --- Shell Utilities & Productivity ---
          ripgrep fd jq yq-go just tmux fzf bat tree
          # --- Network Tools ---
          curl wget speedtest-cli dig bind.dnsutils nmap lsof nghttp2
          # --- Scala Environment ---
          sbt scala-cli jdk17
          # --- Python Environment ---
          python312 uv poetry
          (python312.withPackages (ps: with ps; [ pip setuptools wheel virtualenv conda ])) # Global tools
          # --- Rust Environment ---
          rustc cargo rust-analyzer # Using Nix-provided toolchain
          # --- WebAssembly Support (for Rust) ---
          wasm-pack llvmPackages.lld
          # --- System Libraries ---
          openssl openssl.dev postgresql postgresql.lib libclang clang sqlite zlib libdrm
          # --- Docker & Container Tools ---
          docker docker-compose docker-credential-helpers hadolint steam-run # FHS wrapper
          # --- Supabase Tools ---
          supabase-cli # Assumes supabase-cli is defined elsewhere in pkgs or an overlay
                       # OR reference the custom package definition: (import ./supabase-package.nix { inherit lib stdenv fetchurl autoPatchelfHook; })
          # --- Node.js Environment ---
          nodejs_22 yarn corepack_22 electron # Nix-provided Electron
          # --- Go Environment ---
          go gofumpt golangci-lint
          # --- Browser Automation ---
          chromium playwright-driver
          # --- GUI & Graphics Libraries (Copied directly) ---
          xorg.libX11 xorg.libXcomposite xorg.libXcursor xorg.libXdamage xorg.libXext xorg.libXi xorg.libXrandr xorg.libXScrnSaver xorg.libXtst xorg.libxcb xorg.libXfixes pango cairo cups.lib dbus expat fontconfig freetype libpng nspr nss atk gdk-pixbuf gtk3 alsa-lib glib at-spi2-atk at-spi2-core libxkbcommon udev mesa mesa.drivers libGL
          # --- Filesystem Watcher ---
          inotify-tools
          # --- Infrastructure as Code (IaC) & Cloud ---
          terraform terraform-ls tflint terraform-docs terragrunt pulumi google-cloud-sdk awscli2
        ];

        # --- Copy LD_LIBRARY_PATH (ensure pkgs is available) ---
        LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
          pkgs.stdenv.cc.cc.lib pkgs.xorg.libX11 pkgs.xorg.libXcomposite pkgs.xorg.libXcursor pkgs.xorg.libXdamage pkgs.xorg.libXext pkgs.xorg.libXi pkgs.xorg.libXrandr pkgs.xorg.libXScrnSaver pkgs.xorg.libXtst pkgs.xorg.libxcb pkgs.xorg.libXfixes pkgs.pango pkgs.cairo pkgs.cups.lib pkgs.dbus pkgs.expat pkgs.fontconfig pkgs.freetype pkgs.libpng pkgs.nspr pkgs.nss pkgs.atk pkgs.gdk-pixbuf pkgs.gtk3 pkgs.alsa-lib pkgs.glib pkgs.at-spi2-atk pkgs.at-spi2-core pkgs.libxkbcommon pkgs.udev pkgs.mesa pkgs.libGL pkgs.openssl pkgs.sqlite pkgs.zlib.out pkgs.libdrm
        ];

        # --- Copy 'env' (ensure pkgs variables are resolved correctly) ---
>>>>>>> cadbe02 (Convert legacy dev-shell to flake devShells.default)
        env = {
          PUPPETEER_SKIP_CHROMIUM_DOWNLOAD = "1";
          PUPPETEER_SKIP_DOWNLOAD = "1";
          PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
<<<<<<< HEAD
          PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver}/.drivers";
          CARGO_TARGET_WASM32_UNKNOWN_UNKNOWN_LINKER = "${pkgs.llvmPackages.lld}/bin/lld";
=======
          # Note: Ensure playwright-driver path is correct in the flake's pkgs context
          PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver}/.drivers";
          CARGO_TARGET_WASM32_UNKNOWN_UNKNOWN_LINKER = "${pkgs.llvmPackages.lld}/bin/lld";
          # Ensure cacert path is correct
>>>>>>> cadbe02 (Convert legacy dev-shell to flake devShells.default)
          NODE_EXTRA_CA_CERTS = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
          SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
          GIT_SSL_CAINFO = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
        };

<<<<<<< HEAD
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

        # --- Shell Hook Script (impure actions like npm install, docker check, venv creation) ---
        # This hook runs when you enter `nix develop --impure`
        shellHook = ''
          set -o pipefail
          echo "🔧 Entering Flake-based Comprehensive Development Environment..."
          if [ -z "$HOME" ]; then echo "❌ CRITICAL: \$HOME not set!"; exit 1; fi
          echo "   User: $USER, Home: $HOME, PWD: $PWD"

          # Path Config
          echo "--- Configuring PATH ---"
          if [ -d "$HOME/.local/bin" ]; then export PATH="$HOME/.local/bin:$PATH"; fi
          export GOPATH="$PWD/.go"; export GOBIN="$GOPATH/bin"; export PATH="$GOBIN:$PATH"; mkdir -p "$GOPATH" "$GOBIN"
          export NPM_CONFIG_PREFIX="$HOME/.npm-global"; export PATH="$NPM_CONFIG_PREFIX/bin:$PATH"; mkdir -p "$NPM_CONFIG_PREFIX/bin"
          if [ -d "$PWD/scripts" ]; then export PATH="$PWD/scripts:$PATH"; echo "   Added ./scripts to PATH"; fi

          # Other Env Setup
          mkdir -p "$PWD/.runtime"; export XDG_RUNTIME_DIR="$PWD/.runtime"
          export MANGEKYO_SERVER_URL="http://localhost:17891"

          # Docker/Podman Status
          echo "--- Docker/Podman Status ---"
          # ... (docker/podman check logic as before) ...
          if command -v docker &>/dev/null; then if docker info &>/dev/null; then echo "✅ Docker connected."; else echo "⚠️ Docker daemon conn failed."; fi; alias start-docker='echo "Hint: sudo systemctl start docker.service"';
          elif command -v podman &>/dev/null; then echo "ℹ️ Podman available."; if ! command -v docker &>/dev/null && [ ! -L "$HOME/.local/bin/docker" ]; then mkdir -p "$HOME/.local/bin"; ln -sf "$(which podman)" "$HOME/.local/bin/docker"; echo "   Created Podman alias."; fi;
          else echo "⚠️ Docker/Podman not found."; fi

          # Python Env Setup (uv venv)
          echo "--- Python ($(python --version)) Setup ---"
          # ... (python venv/conda/poetry setup logic as before) ...
=======
        # --- Copy 'shellHook' directly (ensure pkgs variables are accessible) ---
        # !! Be Aware: This hook contains impure actions (npm install -g, venv creation, .env loading) !!
        #    Consider managing tools declaratively where possible long-term.
        shellHook = ''
          set -o pipefail
          echo "🔧 Entering Flake-based Comprehensive Development Environment..."
          if [ -z "$HOME" ]; then echo "❌ CRITICAL: \$HOME not set!"; exit 1; fi
          echo "   User: $USER, Home: $HOME, PWD: $PWD"

          # --- Path Config ---
          echo "--- Configuring PATH ---"
          if [ -d "$HOME/.local/bin" ]; then export PATH="$HOME/.local/bin:$PATH"; fi
          export GOPATH="$PWD/.go"; export GOBIN="$GOPATH/bin"; export PATH="$GOBIN:$PATH"; mkdir -p "$GOPATH" "$GOBIN"
          export NPM_CONFIG_PREFIX="$HOME/.npm-global"; export PATH="$NPM_CONFIG_PREFIX/bin:$PATH"; mkdir -p "$NPM_CONFIG_PREFIX/bin"
          # No longer need PATH manipulation for $HOME/.cargo/bin
          if [ -d "$PWD/scripts" ]; then export PATH="$PWD/scripts:$PATH"; echo "   Added ./scripts to PATH"; fi

          # --- Other Env Setup ---
          mkdir -p "$PWD/.runtime"; export XDG_RUNTIME_DIR="$PWD/.runtime"
          export MANGEKYO_SERVER_URL="http://localhost:17891"

          # --- Docker/Podman Status ---
          echo "--- Docker/Podman Status ---"
          if command -v docker &>/dev/null; then if docker info &>/dev/null; then echo "✅ Docker connected."; else echo "⚠️ Docker daemon conn failed."; fi; alias start-docker='echo "Hint: sudo systemctl start docker.service"';
          elif command -v podman &>/dev/null; then echo "ℹ️ Podman available."; if ! command -v docker &>/dev/null && [ ! -L "$HOME/.local/bin/docker" ]; then mkdir -p "$HOME/.local/bin"; ln -sf "$(which podman)" "$HOME/.local/bin/docker"; echo "   Created Podman alias."; fi;
          else echo "⚠️ Docker/Podman not found."; fi

          # --- Python Env Setup (uses venv creation inside shellHook) ---
          echo "--- Python ($(python --version)) Setup ---"
>>>>>>> cadbe02 (Convert legacy dev-shell to flake devShells.default)
          if command -v uv &>/dev/null; then
              echo "   uv $(uv --version)"
              VENV_DIR=".venv-py$(python -c 'import sys; v=sys.version_info; print(f"{v.major}{v.minor}")')"
              if [ ! -d "$VENV_DIR" ]; then
                  echo "   Creating Python venv ($VENV_DIR)..."
                  uv venv "$VENV_DIR" --python $(which python) || echo "   ⚠️ Failed venv creation."
              fi
<<<<<<< HEAD
              if [ -f "$VENV_DIR/bin/activate" ]; then echo "   🐍 Python venv ready: source $VENV_DIR/bin/activate"; else echo "   ⚠️ Activate script missing: $VENV_DIR"; fi
          else # Fallback to standard venv if uv not found
              echo "   ⚠️ uv not found! Using standard venv."
              VENV_DIR_STD=".venv"
              if [ ! -d "$VENV_DIR_STD" ]; then echo "   Creating venv ($VENV_DIR_STD)..."; python -m venv $VENV_DIR_STD || echo "   ⚠️ Failed venv creation."; fi
              if [ -f "$VENV_DIR_STD/bin/activate" ]; then echo "   🐍 Python venv ready: source $VENV_DIR_STD/bin/activate"; else echo "   ⚠️ Standard venv missing: $VENV_DIR_STD"; fi
          fi
          if command -v conda &>/dev/null; then echo "   Conda $(conda --version)"; eval "$(conda shell.bash hook)" &>/dev/null; echo "   Use 'conda activate <env>'."; else echo "   Conda not found."; fi
          if command -v poetry &>/dev/null; then echo "   Poetry $(poetry --version)"; else echo "   Poetry not found."; fi


          # Node.js Env Setup (npm install -g)
          echo "--- Node.js ($(node -v)) Setup ---"
          echo "   npm $(npm -v), yarn $(yarn --version)"; echo "   Global pkgs: $NPM_CONFIG_PREFIX"; echo "   NOTE: Prefer local deps/Nix pkgs."
          # ... (npm install logic as before) ...
          install_global_npm() { if ! npm list -g "$1" --depth=0 &>/dev/null; then echo "   Installing $1 globally (impure)..."; npm install -g "$1" || echo "   ⚠️ Failed install."; fi; }
          install_global_npm "repomix"; install_global_npm "@anthropic-ai/claude-code"; install_global_npm "@modelcontextprotocol/server-brave-search"; install_global_npm "dotenv-cli"

          # Rust Env Setup (Check Nix tools)
          echo "--- Rust ($(rustc --version 2>/dev/null || echo checking...)) Setup ---"
          # ... (rustc/cargo check logic as before) ...
           if command -v rustc &> /dev/null && command -v cargo &> /dev/null; then echo "   rustc: $(rustc --version)"; echo "   cargo: $(cargo --version)"; else echo "   ⚠️ rustc or cargo command not found in Nix environment!"; fi

          # Go Env Info
          echo "--- Go ($(go version)) Setup ---"; echo "   GOPATH=$GOPATH"

          # Cloud SDKs Info
          echo "--- Cloud SDKs ---"
          # ... (gcloud/aws check logic as before) ...
          if command -v gcloud &>/dev/null; then echo "   GCP SDK available."; else echo "   GCP SDK not found."; fi
          if command -v aws &>/dev/null; then echo "   AWS CLI available."; else echo "   AWS CLI not found."; fi

          # .env File Loading (impure)
          echo "--- Checking/Loading .env file ---"
          # ... (.env loading logic as before) ...
          if [ -f ".env" ]; then echo "   Found .env, loading vars..."; temp_env_vars=$(mktemp --suffix=-dotenv); grep -vE '^\s*(#|$)' .env > "$temp_env_vars" || true; if [ -s "$temp_env_vars" ]; then processed_lines=0; skipped_lines=0; while IFS= read -r line || [ -n "$line" ]; do trimmed_line=$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'); if [[ "$trimmed_line" =~ ^[a-zA-Z_][a-zA-Z0-9_]*=.* ]]; then export "$trimmed_line"; processed_lines=$((processed_lines + 1)); elif [ -n "$trimmed_line" ]; then echo "   ⚠️ Skipping invalid line: '$trimmed_line'"; skipped_lines=$((skipped_lines + 1)); fi; done < "$temp_env_vars"; echo "   ✅ Processed: Loaded $processed_lines vars, skipped $skipped_lines lines."; else echo "   ℹ️ .env found, but no loadable variable lines."; fi; rm "$temp_env_vars"; else echo "   ⚠️ .env file not found."; if [ -f ".env.example" ]; then echo "   💡 Hint: Found '.env.example'."; fi; fi

          # Final Checks & Readiness
          echo ""; echo "✨ Flake Development Environment Ready! ✨"; echo ""
          echo "🩺 Running optional 'claude doctor' check...";
          # ... (claude doctor check logic as before) ...
           if command -v claude &>/dev/null; then claude doctor || echo "   ⚠️ 'claude doctor' error."; else echo "   'claude' CLI not found (use Nix pkg or hook install)."; fi; echo ""
        ''; # End of shellHook
      }; # End of devShells.default


      # --- Checks ---
      # Example check to verify the system builds (remove if not needed)
      checks.${system}.build = self.nixosConfigurations.nixos.config.system.build.toplevel;

      # --- Formatter ---
=======
              if [ -f "$VENV_DIR/bin/activate" ]; then
                  echo "   🐍 Python venv ready: source $VENV_DIR/bin/activate"
              else
                  echo "   ⚠️ Activate script missing: $VENV_DIR"
              fi
          else
              echo "   ⚠️ uv not found!"
              VENV_DIR_STD=".venv"
              if [ ! -d "$VENV_DIR_STD" ]; then
                  echo "   Creating venv ($VENV_DIR_STD)..."
                  python -m venv $VENV_DIR_STD || echo "   ⚠️ Failed venv creation."
              fi
              if [ -f "$VENV_DIR_STD/bin/activate" ]; then
                  echo "   🐍 Python venv ready: source $VENV_DIR_STD/bin/activate"
              else
                  echo "   ⚠️ Standard venv missing: $VENV_DIR_STD"
              fi
          fi
          if command -v conda &>/dev/null; then echo "   Conda $(conda --version)"; eval "$(conda shell.bash hook)" &>/dev/null; echo "   Use 'conda activate <env>'."; else echo "   Conda not found."; fi
          if command -v poetry &>/dev/null; then echo "   Poetry $(poetry --version)"; else echo "   Poetry not found."; fi

          # --- Node.js Env Setup (uses npm install -g inside shellHook) ---
          echo "--- Node.js ($(node -v)) Setup ---"
          echo "   npm $(npm -v), yarn $(yarn --version)"; echo "   Global pkgs: $NPM_CONFIG_PREFIX"; echo "   NOTE: Prefer local deps/Nix pkgs."
          # Define function within hook or call npm directly
          install_global_npm() { if ! npm list -g "$1" --depth=0 &>/dev/null; then echo "   Installing $1 globally (impure)..."; npm install -g "$1" || echo "   ⚠️ Failed install."; fi; }
          install_global_npm "repomix"; install_global_npm "@anthropic-ai/claude-code"; install_global_npm "@modelcontextprotocol/server-brave-search"; install_global_npm "dotenv-cli"

          # --- Rust Env Setup (Checks Nix-provided tools) ---
          echo "--- Rust ($(rustc --version 2>/dev/null || echo checking...)) Setup ---"
          if command -v rustc &> /dev/null && command -v cargo &> /dev/null; then
              echo "   rustc: $(rustc --version)"
              echo "   cargo: $(cargo --version)"
          else
              echo "   ⚠️ rustc or cargo command not found in Nix environment!"
          fi

          # --- Go Env Info ---
          echo "--- Go ($(go version)) Setup ---"; echo "   GOPATH=$GOPATH"
          # --- Cloud SDKs Info ---
          echo "--- Cloud SDKs ---"
          if command -v gcloud &>/dev/null; then echo "   GCP SDK available."; else echo "   GCP SDK not found."; fi
          if command -v aws &>/dev/null; then echo "   AWS CLI available."; else echo "   AWS CLI not found."; fi

          # --- .env File Loading (impure) ---
          echo "--- Checking/Loading .env file ---"
          # (Copied logic for .env loading)
          if [ -f ".env" ]; then echo "   Found .env, loading vars..."; temp_env_vars=$(mktemp --suffix=-dotenv); grep -vE '^\s*(#|$)' .env > "$temp_env_vars" || true; if [ -s "$temp_env_vars" ]; then processed_lines=0; skipped_lines=0; while IFS= read -r line || [ -n "$line" ]; do trimmed_line=$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'); if [[ "$trimmed_line" =~ ^[a-zA-Z_][a-zA-Z0-9_]*=.* ]]; then export "$trimmed_line"; processed_lines=$((processed_lines + 1)); elif [ -n "$trimmed_line" ]; then echo "   ⚠️ Skipping invalid line: '$trimmed_line'"; skipped_lines=$((skipped_lines + 1)); fi; done < "$temp_env_vars"; echo "   ✅ Processed: Loaded $processed_lines vars, skipped $skipped_lines lines."; else echo "   ℹ️ .env found, but no loadable variable lines."; fi; rm "$temp_env_vars"; else echo "   ⚠️ .env file not found."; if [ -f ".env.example" ]; then echo "   💡 Hint: Found '.env.example'."; fi; fi


          # --- Final Checks & Readiness ---
          echo ""; echo "✨ Flake Development Environment Ready! ✨"; echo ""
          echo "🩺 Running optional 'claude doctor' check...";
          if command -v claude &>/dev/null; then claude doctor || echo "   ⚠️ 'claude doctor' error."; else echo "   'claude' CLI not found (use Nix pkg or hook install)."; fi; echo ""
        ''; # End of shellHook
      }; # End of devShells.default

      # --- You might want to keep or remove the other devShells (impure, uv2nix) ---
      # devShells.x86_64-linux.impure = ...
      # devShells.x86_64-linux.uv2nix = ...

      # --- checks.${system} section remains similar ---
      checks.${system} = {
        # ... existing checks ...
      };

      # --- formatter.${system} remains the same ---
>>>>>>> cadbe02 (Convert legacy dev-shell to flake devShells.default)
      formatter.${system} = pkgs.nixpkgs-fmt;
    };
}
