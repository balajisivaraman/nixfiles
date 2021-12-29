{ config, pkgs, lib, ... }:

with lib;
let
  cfg = config.services.update-commodity-prices;
in
{
  options.services.update-commodity-prices = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf cfg.enable {
    systemd.timers.update-commodity-prices = {
      description = "Fetch prices every day at 8AM in the morning";
      wantedBy = [ "timers.target" ];
      after = [ "multi-user.target" ];
      timerConfig = {
        OnCalendar = "*-*-* 03:00:00";
      };
    };
    systemd.services.update-commodity-prices = {
      description = "Fetch prices and update my personal finance repository";
      serviceConfig = {
        Type = "simple";
        Environment = "DISPLAY=:0";
        ExecStart = "${pkgs.bash}/bin/bash --login -c ${pkgs.writeShellScript "update-commodity-prices.sh" (fileContents ./update-commodity-prices.sh)}";
        User = "balaji";
        Group = "users";
      };
    };
  };
}
