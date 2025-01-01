{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.davinci-resolve-studio;
in
{
  options.programs.davinci-resolve-studio = {
    enable = mkEnableOption "DaVinci Resolve Studio";
    package = mkOption {
      type = types.package;
      default = pkgs.davinci-resolve-studio;
      description = "DaVinci Resolve Studio package to use.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    # Optional: Add any specific configurations needed
    environment.sessionVariables = {
      RESOLVE_SCRIPT_API = "${cfg.package}/libs/Fusion/fusionscript.so";
      RESOLVE_SCRIPT_LIB = "${cfg.package}/libs/Fusion/";
      RESOLVE_LIBRARY_PATH = "${cfg.package}/libs/Fusion/";
    };
  };
}
