{ config, pkgs, lib, ... }:

with lib;
let
  cfg = config.services.change-wallpaper;
in
{
  options.services.change-wallpaper = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf cfg.enable {
    systemd.timers.change-wallpaper = {
      description = "Set my wallpaper using feh on boot and in 30 minute intervals";
      wantedBy = [ "timers.target" ];
      after = [ "graphical.target" ];
      timerConfig = {
        OnActiveSec = "0";
        OnUnitActiveSec = "30min";
      };
    };
    systemd.services.change-wallpaper = {
      description = "Change Wallpaper";
      serviceConfig = {
        Type = "simple";
        Environment = "DISPLAY=:0";
        ExecStart = "${pkgs.feh}/bin/feh --bg-fill --randomize /media/backup/Nextcloud/Wallpapers";
        User = "balaji";
        Group = "users";
      };
    };
  };
}
