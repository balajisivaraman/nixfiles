{ config, pkgs, lib, options, ... }:

with lib;
{
  #############################################################################
  ## System Configuration
  #############################################################################

  # Use the systemd-boot EFI boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;

  #############################################################################
  ## Networking
  #############################################################################

  networking.hostName = "andromeda";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s5.useDHCP = true;
  networking.firewall.trustedInterfaces = [ "lo" "enp0s5" ];

  #############################################################################
  ## Package Management
  #############################################################################

  environment.systemPackages = with pkgs;
    [
      xclip
    ];

  #############################################################################
  ## Services
  #############################################################################

  # Every machine gets an sshd
  services.openssh = {
    enable = true;

    # Only pubkey auth
    passwordAuthentication = false;
    challengeResponseAuthentication = false;
  };

  # Start ssh-agent as a systemd user service
  programs.ssh.startAgent = true;
}
