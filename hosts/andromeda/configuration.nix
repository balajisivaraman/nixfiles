{ config, pkgs, lib, options, ... }:

with lib;
{
  #############################################################################
  ## System Configuration
  #############################################################################

  # Use the systemd-boot EFI boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.forceInstall = true;
  boot.loader.grub.device = "nodev";
  boot.loader.timeout = 30;

  #############################################################################
  ## Networking
  #############################################################################

  networking.hostName = "andromeda";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.usePredictableInterfaceNames = false;
  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;
  networking.firewall.trustedInterfaces = [ "lo" "eth0" ];
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  #############################################################################
  ## Package Management
  #############################################################################

  environment.systemPackages = with pkgs;
    [
      inetutils
      mtr
      sysstat
    ];

  #############################################################################
  ## Services
  #############################################################################

  # WWW
  services.caddy.enable = true;
  services.caddy.config = ''
    {
      log {
        level INFO
        output file /var/log/caddy/caddy.log {
          roll_size     100MiB
          roll_keep     5
          roll_keep_for 720h
        }
      }
    }

    (common_config) {
      encode gzip

      header Permissions-Policy "interest-cohort=()"
      header Referrer-Policy "strict-origin-when-cross-origin"
      header Strict-Transport-Security "max-age=31536000; includeSubDomains"
      header X-Content-Type-Options "nosniff"
      header X-Frame-Options "SAMEORIGIN"

      header -Server
    }

    balajisivaraman.com {
      import common_config
      redir https://www.balajisivaraman.com{uri}
    }

    www.balajisivaraman.com {
      import common_config

      file_server {
        root /home/balaji/projects/sites/balajisivaraman.com/www
      }
    }
  '';

  services.fail2ban.enable = true;

  # Every machine gets an sshd
  services.openssh = {
    enable = true;
    # Do not allow root login. We already create the user we need as part of this configuration.
    permitRootLogin = "no";
    # Only pubkey auth
    passwordAuthentication = false;
    challengeResponseAuthentication = false;
  };

  # Start ssh-agent as a systemd user service
  programs.ssh.startAgent = true;
}
