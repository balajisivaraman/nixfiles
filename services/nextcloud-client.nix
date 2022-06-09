{ config, pkgs, lib, ... }:

with lib;
let
  cfg = config.services.nextcloud-client;
in
{
  options.services.nextcloud-client = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf cfg.enable {
    systemd.services.nextcloud-client = {
      description = "Start Nextcloud";
      after = [ "graphical-session-pre.target" ];
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.bash}/bin/bash --login -c ${pkgs.writeShellScript "nextcloud.sh" (fileContents ./nextcloud.sh)}";
        User = "balaji";
        Group = "users";
      };
    };
  };
}
