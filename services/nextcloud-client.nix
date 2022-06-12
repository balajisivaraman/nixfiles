{ config, pkgs, lib, nixpkgs, ... }:

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
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "graphical.target" ];
      partOf = [ "graphical.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.bash}/bin/bash --login -c ${pkgs.writeShellScript "nextcloud.sh" (fileContents ./nextcloud.sh)}";
        User = "balaji";
        Group = "users";
      };
    };
  };
}
