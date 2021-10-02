{ config, pkgs, lib, ... }:

with lib;
let
  cfg = config.services.zotero;
in
{
  options.services.zotero = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf cfg.enable {
    systemd.services.zotero = {
      description = "Start Zotero";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "graphical.target" ];
      partOf = [ "graphical.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.bash}/bin/bash --login -c ${pkgs.writeShellScript "zotero.sh" (fileContents ./zotero.sh)}";
        User = "balaji";
        Group = "users";
      };
    };
  };
}
