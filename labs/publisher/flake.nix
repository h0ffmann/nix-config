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
      ]);
      pythonFor = pkgs: pkgs.python3.withPackages (ps: [ ps.openai ]);
      toolsFor = pkgs: [ pkgs.pandoc (texFor pkgs) (pythonFor pkgs) pkgs.just pkgs.poppler-utils ];

      # mkPdf: run `command` inside `src` with this toolchain in the Nix sandbox and collect
      # every PDF the command leaves in $OUT_DIR. The consumer owns the sources and the script.
      #
      #   publisher.lib.${system}.mkPdf {
      #     name = "my-report";
      #     src = ./.;                              # or a filtered source
      #     command = "bash scripts/build_pdf.sh book";
      #   }
      mkPdfFor = pkgs: { name, src, command }: pkgs.stdenv.mkDerivation {
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
          cp "$TMPDIR"/out/*.pdf "$out"/
        '';
      };
    in
    {
      lib = forAll (pkgs: {
        tex = texFor pkgs;
        python = pythonFor pkgs;
        tools = toolsFor pkgs;
        mkPdf = mkPdfFor pkgs;
      });

      devShells = forAll (pkgs: {
        default = pkgs.mkShell {
          name = "publisher";
          packages = toolsFor pkgs;
          shellHook = ''
            echo "publisher: pandoc $(pandoc --version | head -1 | cut -d' ' -f2) | $(xelatex --version | head -1)"
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
      });

      # CI (nix flake check) builds this: pandoc → xelatex and pandoc → pdflatex on a sample with
      # math, a table, code, Portuguese hyphenation and a citation — everything the documents use.
      checks = forAll (pkgs: {
        smoke = self.packages.${pkgs.system}.smoke;
      });
    };
}
