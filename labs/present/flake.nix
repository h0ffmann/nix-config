{
  description = "present — screen annotation, capture and recording, webcam controls (v4l2 + the `cam` profile script), and terminal/PDF presenters, for talks and demos on a Linux desktop";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      forAll = f: lib.genAttrs systems (s: f nixpkgs.legacyPackages.${s});

      # `cam` resolves v4l2-ctl from the caller's PATH on purpose: its --self-test fakes it, and
      # writeShellApplication prepends runtimeInputs, which would shadow the fake.
      camFor = pkgs: pkgs.writeShellApplication {
        name = "cam";
        runtimeInputs = [ pkgs.coreutils pkgs.gawk pkgs.gnused pkgs.gnugrep ];
        text = builtins.readFile ./scripts/cam;
      };

      # Everything that runs without a display server, on every system.
      cliFor = pkgs: with pkgs; [
        presenterm # markdown decks in the terminal
        ffmpeg # trims, re-encodes, x11grab
        gifski # mp4 → gif that does not look like 1998
      ];

      # The desktop half. Wayland tools and X11 tools both go in: the workstation switches, and
      # the justfile picks by $WAYLAND_DISPLAY. No macOS equivalents in nixpkgs (Presentify and
      # friends are App Store only); the README says what to install by hand there.
      desktopFor = pkgs: with pkgs; [
        gromit-mpx # draw over any window; hotkey-toggled
        find-cursor # cursor spotlight
        screenkey # keystrokes on screen (X11)
        wshowkeys # keystrokes on screen (Wayland)
        flameshot # screenshot + annotate (X11, and Wayland via portal)
        grim
        slurp
        satty # grim + slurp + satty: Wayland-native shot → annotate
        wf-recorder # Wayland screen recording, CLI
        kooha # Wayland screen recording, GUI
        obs-studio # webcam overlay, scenes, streaming
        v4l-utils # v4l2-ctl, what `cam` drives
        cameractrls # every V4L2 control in a GUI, with presets
        guvcview # webcam preview
        pdfpc # PDF presenter console: notes, timer, next slide
        (camFor pkgs)
      ];

      toolsFor = pkgs: cliFor pkgs ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux (desktopFor pkgs);

      selfTest = pkgs: drv: pkgs.runCommand "${drv.name}-self-test" { } ''
        ${drv}/bin/${drv.name} --self-test | tee "$out"
      '';

      # Only tools that answer --version without a display: a GUI app launched in the sandbox
      # would hang on a missing socket, not fail cleanly.
      versionsFor = pkgs:
        let
          linux = pkgs.stdenv.hostPlatform.isLinux;
          linuxTools = lib.optionals linux (with pkgs; [ v4l-utils wf-recorder grim slurp pdfpc gromit-mpx ]);
        in
        pkgs.runCommand "present-versions" { nativeBuildInputs = cliFor pkgs ++ linuxTools; } ''
          {
            echo "nixpkgs     ${nixpkgs.rev or "dirty"}"
            echo "presenterm  $(presenterm --version)"
            echo "ffmpeg      $(ffmpeg -version | head -1 | cut -d' ' -f3)"
            echo "gifski      $(gifski --version)"
            ${lib.optionalString linux ''
              echo "v4l2-ctl    $(v4l2-ctl --version)"
              echo "wf-recorder $(wf-recorder --version)"
              # grim, slurp and gromit-mpx have no --version; pdfpc's needs fontconfig. They are
              # in nativeBuildInputs so a nixpkgs bump that drops one still fails this build.
              echo "grim        ${pkgs.grim.version}"
              echo "slurp       ${pkgs.slurp.version}"
              echo "pdfpc       ${pkgs.pdfpc.version}"
              echo "gromit-mpx  ${pkgs.gromit-mpx.version}"
            ''}
          } | tee versions.txt
          mkdir -p "$out" && cp versions.txt "$out"/
        '';
    in
    {
      lib = forAll (pkgs: {
        tools = toolsFor pkgs;
        scripts = { cam = camFor pkgs; };
      });

      packages = forAll (pkgs: {
        cam = camFor pkgs;
        versions = versionsFor pkgs;
        inherit (pkgs) presenterm ffmpeg gifski;
      } // lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
        inherit (pkgs) gromit-mpx flameshot grim slurp satty wf-recorder kooha obs-studio v4l-utils cameractrls guvcview pdfpc screenkey wshowkeys find-cursor;
      });

      devShells = forAll (pkgs: {
        default = pkgs.mkShell {
          name = "present";
          packages = toolsFor pkgs;
          shellHook = ''echo "present: $(command -v gromit-mpx >/dev/null && echo 'gromit-mpx, flameshot, wf-recorder, obs, cam' || echo 'terminal tools only on this OS') | presenterm $(presenterm --version | cut -d' ' -f2)"'';
        };
      });

      # Built by `nix flake check`: the script's self-test against a fake v4l2-ctl, and the CLI
      # tools' versions — no camera, no display, no GUI launched in the sandbox.
      checks = forAll (pkgs: {
        cam = selfTest pkgs (camFor pkgs);
        versions = self.packages.${pkgs.stdenv.hostPlatform.system}.versions;
      });
    };
}
