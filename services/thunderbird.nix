{ config, pkgs, lib, ... }:

with lib;
let
  cfg = config.services.thunderbird;
in
{
  options.services.thunderbird = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf cfg.enable {
    systemd.services.thunderbird = {
      description = "Start Thunderbird";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "graphical.target" ];
      partOf = [ "graphical.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.bash}/bin/bash --login -c ${pkgs.writeShellScript "thunderbird.sh" (fileContents ./thunderbird.sh)}";
        User = "balaji";
        Group = "users";
      };
    };
  };
}
