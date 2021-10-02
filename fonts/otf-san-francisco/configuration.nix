{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.fonts.otf-san-francisco;
in
{
  options = {
    fonts = {
      otf-san-francisco = {
        enable = mkOption { type = types.bool; default = false; };
      };
    };
  };

  config = mkIf cfg.enable {
    fonts.fonts =
      let
        otf-san-francisco = pkgs.callPackage ./. { };
      in
        [ otf-san-francisco ];
  };
}
