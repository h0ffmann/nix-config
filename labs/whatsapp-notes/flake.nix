{
  description = "whatsapp-notes — WhatsApp voice notes (.opus) to mp3/wav/m4a with ffmpeg, and to text offline with whisper.cpp";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # locked to the same rev as labs/gleam-website
  };

  outputs = { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      forAll = f: lib.genAttrs systems (s: f nixpkgs.legacyPackages.${s});

      # ffmpeg-headless: the Opus decoder and the mp3/aac/vorbis encoders, without X11 and SDL.
      # whisper-cpp is the CPU build; `whisper-cpp.override { cudaSupport = true; }` is the GPU one.
      externalFor = pkgs: with pkgs; [ ffmpeg-headless whisper-cpp curl ];

      # The tools are appended to PATH, not prepended as runtimeInputs would: --self-test puts
      # fake ffmpeg, whisper-cli and curl first on PATH, and they must win.
      waNotesFor = pkgs: pkgs.writeShellApplication {
        name = "wa-notes";
        runtimeInputs = [ pkgs.coreutils pkgs.findutils pkgs.gnugrep pkgs.gnused ];
        text = ''
          export PATH="$PATH:${lib.makeBinPath (externalFor pkgs)}"
        '' + builtins.readFile ./scripts/wa-notes;
        meta.license = lib.licenses.agpl3Only;
      };

      toolsFor = pkgs: externalFor pkgs ++ [ pkgs.just (waNotesFor pkgs) ];

      selfTest = pkgs: drv: pkgs.runCommand "${drv.name}-self-test" { } ''
        ${drv}/bin/${drv.name} --self-test | tee "$out"
      '';

      versionsFor = pkgs: pkgs.runCommand "whatsapp-notes-versions" { nativeBuildInputs = toolsFor pkgs; } ''
        {
          echo "nixpkgs      ${nixpkgs.rev or "dirty"}"
          echo "ffmpeg       $(ffmpeg -version | head -1 | cut -d' ' -f3)"
          echo "whisper-cpp  ${pkgs.whisper-cpp.version}"
          echo "just         $(just --version)"
        } | tee versions.txt
        whisper-cli --help >/dev/null 2>&1
        mkdir -p "$out" && cp versions.txt "$out"/
      '';

      # A voice note without WhatsApp: one second of tone encoded as Opus in Ogg, as WhatsApp saves
      # it, then `wa-notes convert` to every target format with the real ffmpeg. Transcription
      # needs a model download, so the sandbox covers it with the self-test's fakes only.
      smokeFor = pkgs: pkgs.runCommand "whatsapp-notes-smoke" { nativeBuildInputs = toolsFor pkgs; } ''
        mkdir chat
        ffmpeg -nostdin -hide_banner -loglevel error -f lavfi -i "sine=frequency=440:duration=1" \
          -ac 1 -c:a libopus -b:a 16k chat/PTT-20261012-WA0001.opus
        for to in mp3 wav m4a ogg; do wa-notes convert --to "$to" chat; done
        for to in mp3 wav m4a ogg; do
          d="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "chat/PTT-20261012-WA0001.$to")"
          echo "$to $d"
          awk -v d="$d" 'BEGIN { exit !(d > 0.9 && d < 1.2) }'
        done
        mkdir -p "$out" && cp chat/* "$out"/
      '';

      # lab.json, the card the profile README renders: its shape is asserted at evaluation, and the
      # build writes each headline attribute's version from this lab's own nixpkgs. Copied in every
      # lab, since a lab references nothing outside itself.
      labCardFor = pkgs:
        let
          card = lib.importJSON ./lab.json;
          version = attr: (lib.getAttrFromPath (lib.splitString "." attr) pkgs).version;
        in
        assert lib.assertMsg (lib.isString card.summary && card.summary != "" && lib.stringLength card.summary <= 100)
          "lab.json: summary must be one non-empty line of at most 100 characters";
        assert lib.assertMsg (lib.isList card.headline && card.headline != [ ] && lib.all lib.isString card.headline)
          "lab.json: headline must be a non-empty list of nixpkgs attribute paths";
        pkgs.writeText "lab-json" (lib.concatMapStrings (a: "${a} ${version a}\n") card.headline);
    in
    {
      lib = forAll (pkgs: {
        tools = toolsFor pkgs;
        scripts = { wa-notes = waNotesFor pkgs; };
      });

      devShells = forAll (pkgs: {
        default = pkgs.mkShell {
          name = "whatsapp-notes";
          packages = toolsFor pkgs;
          shellHook = ''echo "whatsapp-notes: wa-notes | ffmpeg $(ffmpeg -version | head -1 | cut -d' ' -f3) | whisper.cpp ${pkgs.whisper-cpp.version}"'';
        };
      });

      packages = forAll (pkgs: {
        default = waNotesFor pkgs;
        wa-notes = waNotesFor pkgs;
        versions = versionsFor pkgs;
        smoke = smokeFor pkgs;
        inherit (pkgs) whisper-cpp ffmpeg-headless;
      });

      checks = forAll (pkgs: {
        lab-json = labCardFor pkgs;
        wa-notes = selfTest pkgs (waNotesFor pkgs);
        versions = self.packages.${pkgs.stdenv.hostPlatform.system}.versions;
        smoke = self.packages.${pkgs.stdenv.hostPlatform.system}.smoke;
      });
    };
}
