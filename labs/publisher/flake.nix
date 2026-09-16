{
  description = "publisher — markdown → LaTeX → PDF toolchain (pandoc, TeX Live, python+openai) and a mkPdf helper for sandboxed document builds";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # locked to the same rev as labs/pratico
  };

  outputs = { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      forAll = f: lib.genAttrs systems (s: f nixpkgs.legacyPackages.${s});

      # TeX Live: scheme-medium plus what the ww-lab documents need (found with \listfiles).
      # xelatex (book: DejaVu by filename, no fontconfig) and pdflatex (UFRJ proposal) both come
      # from this one environment.
      texFor = pkgs: pkgs.texliveMedium.withPackages (ps: with ps; [
        babel-portuges
        hyphen-portuguese
        dejavu
        fontspec
        unicode-math
        xetex
        booktabs
        caption
        enumitem
        float
        multirow
        tools
        framed
        fvextra
        lineno
        microtype
        titlesec
        upquote
        xcolor
        csquotes
        luatexja # Japanese typesetting under lualatex (CJK line breaking, jfonts)
        # luatexja's default jfont and the one to use: static OTFs (nixpkgs' Noto Sans CJK is a
        # variable-font collection luatexja cannot instantiate for bold or vertical faces)
        haranoaji
      ]);
      pythonFor = pkgs: pkgs.python3.withPackages (ps: [ ps.openai ]);
      # librsvg: pandoc's LaTeX writer converts SVG images with rsvg-convert.
      toolsFor = pkgs: [ pkgs.pandoc (texFor pkgs) (pythonFor pkgs) pkgs.just pkgs.poppler-utils pkgs.librsvg ];

      # What a consumer's pandoc/lualatex needs to find this lab's filter, style and emoji font.
      # Exported by mkPdf and the devShell; also exposed as lib.<system>.env.
      envFor = pkgs: {
        PUBLISHER_FILTERS = "${self}/filters";
        TEXINPUTS = "${self}/tex//:";
        # luaotfload: "Noto Color Emoji" (emoji fallback). kpathsea list: keep the `//` (search
        # subdirectories) suffix on every entry — with more than one plain entry luaotfload's
        # database finds nothing in the sandbox. Japanese uses Harano Aji from the TeX tree.
        OSFONTDIR = "${pkgs.noto-fonts-color-emoji}/share/fonts//";
      };

      # mkDocument: run `command` inside `src` with this toolchain in the Nix sandbox and collect
      # the documents it leaves in $OUT_DIR. The consumer owns the sources and the script.
      # `formats` lists the extensions to collect; the build fails when it produced none of them.
      #
      #   publisher.lib.${system}.mkPdf  { name = "my-report"; src = ./.; command = "..."; }
      #   publisher.lib.${system}.mkDocx { name = "my-report-docx"; src = ./.; command = "..."; }
      #   publisher.lib.${system}.mkDocument { ...; formats = [ "pdf" "docx" ]; }
      mkDocumentFor = pkgs: { name, src, command, formats ? [ "pdf" ] }: pkgs.stdenv.mkDerivation ({
        inherit name src;
        nativeBuildInputs = toolsFor pkgs;
        dontConfigure = true;
        buildPhase = ''
          export HOME=$TMPDIR TEXMFVAR=$TMPDIR/texmf-var OUT_DIR=$TMPDIR/out
          mkdir -p "$OUT_DIR"
          ${command}
        '';
        installPhase = ''
          mkdir -p "$out"
          shopt -s nullglob
          collected=0
          for ext in ${lib.concatStringsSep " " formats}; do
            for doc in "$TMPDIR"/out/*."$ext"; do
              cp "$doc" "$out"/
              collected=$((collected + 1))
            done
          done
          if [ "$collected" -eq 0 ]; then
            echo "publisher: ${name} produced no ${lib.concatStringsSep "/" formats} file in \$OUT_DIR" >&2
            exit 1
          fi
        '';
      } // envFor pkgs);

      mkPdfFor = pkgs: args: mkDocumentFor pkgs ({ formats = [ "pdf" ]; } // args);
      mkDocxFor = pkgs: args: mkDocumentFor pkgs ({ formats = [ "docx" ]; } // args);
    in
    {
      lib = forAll (pkgs: {
        tex = texFor pkgs;
        python = pythonFor pkgs;
        tools = toolsFor pkgs;
        mkPdf = mkPdfFor pkgs;
        mkDocx = mkDocxFor pkgs;
        mkDocument = mkDocumentFor pkgs;
        env = envFor pkgs;
      });

      devShells = forAll (pkgs: {
        default = pkgs.mkShell {
          name = "publisher";
          packages = toolsFor pkgs;
          shellHook = ''
            ${lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "export ${k}=${lib.escapeShellArg v}") (envFor pkgs))}
            echo "publisher: pandoc $(pandoc --version | head -1 | cut -d' ' -f2) | $(xelatex --version | head -1) | $(lualatex --version | head -1)"
          '';
        };
      });

      packages = forAll (pkgs: {
        tex = texFor pkgs;
        # The smoke document, so `nix build .#smoke` shows a real PDF from this toolchain.
        smoke = mkPdfFor pkgs {
          name = "publisher-smoke";
          src = ./example;
          command = "bash build.sh";
        };
        # The same sample as .docx: pandoc's docx writer, no TeX in the path.
        smoke-docx = mkDocxFor pkgs {
          name = "publisher-smoke-docx";
          src = ./example;
          command = "bash build-docx.sh";
        };
      });

      # CI (nix flake check) builds this: pandoc → xelatex and pandoc → pdflatex on a sample with
      # math, a table, code, Portuguese hyphenation and a citation — everything the documents use.
      checks = forAll (pkgs: {
        smoke = self.packages.${pkgs.system}.smoke;
        # docx is optional for consumers but not untested here: the writer must produce a real
        # document part with the sample's text and citation in it (example/build-docx.sh).
        docx = self.packages.${pkgs.system}.smoke-docx;
        # The shields filter alone, to LaTeX source: exact \badge macros for every badge shape.
        filter = pkgs.runCommand "publisher-filter-check" ({ nativeBuildInputs = [ pkgs.pandoc ]; } // envFor pkgs) ''
          export OUT_DIR=$TMPDIR/out
          bash ${./example}/check-filter.sh
          mkdir -p "$out" && cp "$OUT_DIR"/badges.tex "$out"/
        '';
      });
    };
}
