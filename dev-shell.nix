# /etc/nixos/dev-shell.nix or ~/your/project/shell.nix
# A comprehensive development environment shell using Nix legacy mechanism (mkShell).
{ pkgs ? import <nixpkgs> {
    # Configuration for the nixpkgs instance used
    config = {
      allowUnfree = true; # Allow proprietary packages (e.g., drivers, some apps)
      allowBroken = true; # Allow packages marked as broken (USE WITH CAUTION)
      # Only list packages here that you explicitly understand the security risks of
      permittedInsecurePackages = [
        # e.g., "openssl-1.1.1"
      ];
    };
  }
}:

pkgs.mkShell {
  # Name for the shell (useful for some prompts/tools)
  name = "h0ffmann-devshell";

  # List of packages to make available in the shell's PATH
  packages = with pkgs; [
    # --- Core Build & System Tools ---
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

    # --- Python Environment ---
    python312
    uv
    poetry
    (python312.withPackages (ps: with ps; [
      pip
      setuptools
      wheel
      virtualenv
      conda
      # Add Python libraries here if needed globally in the shell
    ]))

    # --- Rust Environment ---
    # rustup # REMOVED - Use Nix toolchain below
    rustc   # ADDED - Nix-provided Rust compiler
    cargo   # ADDED - Nix-provided Cargo build tool/package manager
    rust-analyzer

    # --- WebAssembly Support (for Rust) ---
    wasm-pack
    llvmPackages.lld

    # --- System Libraries often needed ---
    openssl
    openssl.dev
    postgresql
    postgresql.lib
    libclang
    clang
    sqlite
    zlib
    libdrm # Required by Electron/GUI frameworks

    # --- Docker & Container Tools ---
    docker
    docker-compose
    docker-credential-helpers
    hadolint
    steam-run # ADDED - FHS environment wrapper

    # --- Supabase Tools ---
    supabase-cli

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
    pulumi
    google-cloud-sdk
    awscli2
  ];

  # Defines the LD_LIBRARY_PATH with necessary system libraries.
  # Keeping this comprehensive list as Electron and other GUI tools might need it.
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

  # Environment variables set by Nix *before* shellHook runs
  env = {
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD = "1";
    PUPPETEER_SKIP_DOWNLOAD = "1";
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
    PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver}/.drivers";
    CARGO_TARGET_WASM32_UNKNOWN_UNKNOWN_LINKER = "${pkgs.llvmPackages.lld}/bin/lld"; # Still needed for wasm-pack
    NODE_EXTRA_CA_CERTS = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    GIT_SSL_CAINFO = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
  };

  # Script executed when entering the Nix shell environment
  shellHook = ''
    set -o pipefail
    echo "🔧 Entering Comprehensive Development Environment (Shell)..."
    if [ -z "$HOME" ]; then echo "❌ CRITICAL: \$HOME not set!"; exit 1; fi
    echo "   User: $USER, Home: $HOME, PWD: $PWD"

    # --- Path Config ---
    echo "--- Configuring PATH ---"
    if [ -d "$HOME/.local/bin" ]; then export PATH="$HOME/.local/bin:$PATH"; fi
    export GOPATH="$PWD/.go"; export GOBIN="$GOPATH/bin"; export PATH="$GOBIN:$PATH"; mkdir -p "$GOPATH" "$GOBIN"
    export NPM_CONFIG_PREFIX="$HOME/.npm-global"; export PATH="$NPM_CONFIG_PREFIX/bin:$PATH"; mkdir -p "$NPM_CONFIG_PREFIX/bin"
    # export PATH="$HOME/.cargo/bin:$PATH" # REMOVED - Rely on Nix path for rustc/cargo
    if [ -d "$PWD/scripts" ]; then export PATH="$PWD/scripts:$PATH"; echo "   Added ./scripts to PATH"; fi

    # --- Other Env Setup ---
    mkdir -p "$PWD/.runtime"; export XDG_RUNTIME_DIR="$PWD/.runtime"
    export MANGEKYO_SERVER_URL="http://localhost:17891"

    # --- Docker/Podman Status ---
    echo "--- Docker/Podman Status ---"
    if command -v docker &>/dev/null; then if docker info &>/dev/null; then echo "✅ Docker connected."; else echo "⚠️ Docker daemon conn failed."; fi; alias start-docker='echo "Hint: sudo systemctl start docker.service"';
    elif command -v podman &>/dev/null; then echo "ℹ️ Podman available."; if ! command -v docker &>/dev/null && [ ! -L "$HOME/.local/bin/docker" ]; then mkdir -p "$HOME/.local/bin"; ln -sf "$(which podman)" "$HOME/.local/bin/docker"; echo "   Created Podman alias."; fi;
    else echo "⚠️ Docker/Podman not found."; fi

    # --- Python Env Setup ---
    echo "--- Python ($(python --version)) Setup ---"
    if command -v uv &>/dev/null; then
        echo "   uv $(uv --version)"
        # Corrected f-string syntax: removed '\' before '{'
        VENV_DIR=".venv-py$(python -c 'import sys; v=sys.version_info; print(f"{v.major}{v.minor}")')"
        if [ ! -d "$VENV_DIR" ]; then
            echo "   Creating Python venv ($VENV_DIR)..."
            uv venv "$VENV_DIR" --python $(which python) || echo "   ⚠️ Failed venv creation."
        fi
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

    # --- Node.js Env Setup ---
    echo "--- Node.js ($(node -v)) Setup ---"
    echo "   npm $(npm -v), yarn $(yarn --version)"; echo "   Global pkgs: $NPM_CONFIG_PREFIX"; echo "   NOTE: Prefer local deps."
    install_global_npm() { if ! npm list -g "$1" --depth=0 &>/dev/null; then echo "   Installing $1 globally..."; npm install -g "$1" || echo "   ⚠️ Failed install."; fi; }
    install_global_npm "repomix"; install_global_npm "@anthropic-ai/claude-code"; install_global_npm "@modelcontextprotocol/server-brave-search"; install_global_npm "dotenv-cli"

    # --- Rust Env Setup ---
    # Modified to check for nix-provided rustc/cargo
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

    # --- .env File Loading ---
    echo "--- Checking/Loading .env file ---"
    if [ -f ".env" ]; then echo "   Found .env, loading vars..."; temp_env_vars=$(mktemp --suffix=-dotenv); grep -vE '^\s*(#|$)' .env > "$temp_env_vars" || true; if [ -s "$temp_env_vars" ]; then processed_lines=0; skipped_lines=0; while IFS= read -r line || [ -n "$line" ]; do trimmed_line=$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'); if [[ "$trimmed_line" =~ ^[a-zA-Z_][a-zA-Z0-9_]*=.* ]]; then export "$trimmed_line"; processed_lines=$((processed_lines + 1)); elif [ -n "$trimmed_line" ]; then echo "   ⚠️ Skipping invalid line: '$trimmed_line'"; skipped_lines=$((skipped_lines + 1)); fi; done < "$temp_env_vars"; echo "   ✅ Processed: Loaded $processed_lines vars, skipped $skipped_lines lines."; else echo "   ℹ️ .env found, but no loadable variable lines."; fi; rm "$temp_env_vars"; else echo "   ⚠️ .env file not found."; if [ -f ".env.example" ]; then echo "   💡 Hint: Found '.env.example'."; fi; fi

    # --- Final Checks & Readiness ---
    echo ""; echo "✨ Comprehensive Development Environment Ready! ✨"; echo ""
    echo "🩺 Running optional 'claude doctor' check...";
    if command -v claude &>/dev/null; then claude doctor || echo "   ⚠️ 'claude doctor' error."; else echo "   'claude' CLI not found."; fi; echo ""
  '';
}
