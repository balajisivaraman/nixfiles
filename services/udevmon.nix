{ config, pkgs, lib, ... }:

with lib;
let
  cfg = config.services.udevmon;
in
{
  options.services.udevmon = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf cfg.enable {
    services.interception-tools = {
      enable = true;
      plugins = [ pkgs.interception-tools-plugins.dual-function-keys ];
      udevmonConfig = ''
      - JOB: "${pkgs.interception-tools}/bin/intercept -g $DEVNODE | ${pkgs.interception-tools-plugins.dual-function-keys}/bin/dual-function-keys -c /home/balaji/.dual-function-keys.yaml | ${pkgs.interception-tools}/bin/uinput -d $DEVNODE"
        DEVICE:
          EVENTS:
            EV_KEY: [KEY_ENTER, KEY_TAB, KEY_BACKSLASH]
  '';
    };
  };
}
