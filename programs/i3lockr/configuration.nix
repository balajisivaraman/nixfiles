{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.i3lockr;
in
{
  options = {
    programs = {
      i3lockr = {
        enable = mkOption { type = types.bool; default = false; };
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages =
      let
        i3lockr = pkgs.callPackage ./. { };
      in
        [ i3lockr ];
  };
}
