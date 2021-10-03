{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.bs-emacs;
in
{
  options = {
    programs = {
      bs-emacs = {
        enable = mkOption { type = types.bool; default = false; };
      };
    };
  };

  config = mkIf cfg.enable {
    services.emacs.package = pkgs.emacsPgtkGcc;
    nixpkgs.overlays = [
      (import (builtins.fetchGit {
        url = "https://github.com/nix-community/emacs-overlay.git";
        ref = "master";
        rev = "30d84ab85192f19beaa7a9af4640d8f4a2e74da5"; # change the revision
      }))
    ];
    environment.systemPackages = [ pkgs.emacsPgtkGcc ];
    systemd.services.bs-emacs = {
      description = "Start Emacs as a Daemon";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "graphical.target" ];
      partOf = [ "graphical.target" ];
      serviceConfig = {
        Type = "simple";
        Environment= [ "SSH_AUTH_SOCK=%t/keyring/ssh" ];
        ExecStart = "${pkgs.emacsPgtkGcc}/bin/emacs --fg-daemon";
        ExecStop = "${pkgs.emacsPgtkGcc}/bin/emacsclient --eval \"(kill-emacs)\"";
        User = "balaji";
        Group = "users";
        Restart= "on-failure";
      };
    };
  };
}
