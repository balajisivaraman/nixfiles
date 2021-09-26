{ config, pkgs, options, ... }:

{
  #############################################################################
  ## System Configuration
  #############################################################################

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  #############################################################################
  ## Networking
  #############################################################################

  networking.hostName = "europa";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s3.useDHCP = true;
  networking.firewall.trustedInterfaces = [ "lo" "enp0s3" ];

  #############################################################################
  ## X Server & Desktop Environment Configuration
  #############################################################################

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    displayManager = {
      autoLogin.enable = true;
      autoLogin.user = "balaji";
      defaultSession = "none+i3";
    };
    windowManager.i3 = {
      package = pkgs.i3-gaps;
      enable = true;
    };
  };

  services.gnome.gnome-keyring.enable = true;

  # Enable nvidia graphics
  services.xserver.videoDrivers = [ "nvidia" ];

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  #############################################################################
  ## Package Management
  #############################################################################

  services.emacs.package = pkgs.emacsPgtkGcc;

  nixpkgs.overlays =
  let
    # Change this to a rev sha to pin
    moz-rev = "master";
    moz-url = builtins.fetchTarball { url = "https://github.com/mozilla/nixpkgs-mozilla/archive/${moz-rev}.tar.gz";};
    nightlyOverlay = (import "${moz-url}/firefox-overlay.nix");
  in [
    (import (builtins.fetchGit {
      url = "https://github.com/nix-community/emacs-overlay.git";
      ref = "master";
      rev = "30d84ab85192f19beaa7a9af4640d8f4a2e74da5"; # change the revision
    }))
    nightlyOverlay
  ];

  environment.systemPackages = with pkgs; [
    alacritty
    aspell
    aspellDicts.en
    cantata
    emacsPgtkGcc
    feh
    fnm
    flameshot
    gimp
    google-chrome
    gparted
    imagemagick
    keepassxc
    latest.firefox-nightly-bin
    nextcloud-client
    polybar
    rofi
    starship
    vlc
    xclip
  ];

  #############################################################################
  ## Virtualisation
  #############################################################################

  # Enable guest additions on the VM
  virtualisation.virtualbox.guest.enable = true;

  # Enable the host shared folder
  fileSystems."/mnt/HostShare" = {
    fsType = "vboxsf";
    device = "Share";
    options = [ "rw" "nofail" ];
  };
}
