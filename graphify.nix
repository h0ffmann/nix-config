# graphify (code → knowledge graph, https://github.com/Graphify-Labs/graphify) is not in nixpkgs and
# pins ~30 tree-sitter wheels, so it runs from PyPI through uv instead of being packaged here. On
# NixOS uv's downloaded Python needs programs.nix-ld (configuration.nix).
{ writeShellApplication, uv }:
writeShellApplication {
  name = "graphify";
  runtimeInputs = [ uv ];
  text = ''
    exec uv tool run --from graphifyy==0.9.85 graphify "$@"
  '';
}
