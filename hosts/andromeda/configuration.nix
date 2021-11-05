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
  networking.firewall.trustedInterfaces = [ "lo" "enp0s5" ];

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
