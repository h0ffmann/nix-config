# The rebuild experiment in §5 of the whitepaper. A factory-layer OCI image made of the host tools
# Yggdrasil's check ladder names, from picasso's lint-lab nixpkgs pin. Run it twice and compare:
#   nix-build image.nix -o img && sha256sum "$(readlink -f img)"
#   nix-build image.nix --check     # rebuilds locally; fails if a single bit differs
{ nixpkgs ? builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/eaad089433ca2bb662274377d33df3d0e51ef28b.tar.gz";
  }
}:
let pkgs = import nixpkgs { };
in pkgs.dockerTools.buildLayeredImage {
  name = "factory-layer-demo";
  tag = "eaad0894";
  contents = with pkgs; [ bashInteractive coreutils git go gitleaks govulncheck golangci-lint vale osv-scanner ];
  config.User = "1000:1000";
}
