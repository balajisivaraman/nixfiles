{ config, pkgs, lib, ... }:

with lib;
let
  cfg = config.services.hledger-to-influxdb;
in
{
  options.services.hledger-to-influxdb = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf cfg.enable {
    systemd.timers.hledger-to-influxdb = {
      description = "Read my Hledger journal file and dump data into InfluxDB.";
      wantedBy = [ "timers.target" ];
      after = [ "multi-user.target" ];
      timerConfig = {
        OnCalendar = "*-*-* 04:00:00";
      };
    };
    systemd.services.hledger-to-influxdb = {
      description = "Read my Hledger journal file and dump data into InfluxDB.";
      serviceConfig = {
        Type = "simple";
        Environment = "DISPLAY=:0";
        ExecStart = "${pkgs.bash}/bin/bash --login -c ${pkgs.writeShellScript "hledger-to-influxdb.sh" (fileContents ./hledger-to-influxdb.sh)}";
        User = "balaji";
        Group = "users";
      };
    };
  };
}
