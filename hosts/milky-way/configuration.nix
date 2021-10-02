{ config, pkgs, lib, options, ... }:

with lib;
{
  #############################################################################
  ## System Configuration
  #############################################################################

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ];

  #############################################################################
  ## Networking
  #############################################################################

  networking.hostName = "milky-way";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp40s0.useDHCP = true;
  networking.firewall.trustedInterfaces = [ "lo" "enp40s0" ];

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

  fonts.otf-san-francisco.enable = true;
  services.emacs.package = pkgs.emacsPgtkGcc;
  programs.gnupg.agent.pinentryFlavor = "qt";
  services.change-wallpaper.enable = true;
  services.thunderbird.enable = true;
  services.nextcloud-client.enable = true;
  services.zotero.enable = true;

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
    (import "${fetchTarball "https://github.com/nix-community/fenix/archive/main.tar.gz"}/overlay.nix")
    nightlyOverlay
  ];

  environment.systemPackages = with pkgs;
    let
      polybar = pkgs.polybar.override {
        i3Support = true;
        i3GapsSupport = true;
        pulseSupport = true;
      };
    in
      [
        alacritty
        aspell
        aspellDicts.en
        binutils
        cantata
        delta
        dunst
        emacsPgtkGcc
        feh
        flameshot
        gcc
        gimp
        google-chrome
        gparted
        imagemagick
        keepassxc
        latest.firefox-nightly-bin
        libnotify
        libreoffice-fresh
        libsecret
        lxsession
        nextcloud-client
        pamixer
        pavucontrol
        pcmanfm
        picom
        polybar
        qtkeychain
        rofi
        rust-analyzer
        rustup
        starship
        nordic
        thunderbird
        udiskie
        vlc
        xcape
        xclip
        xorg.xmodmap
        zathura
        zotero
      ];

  #############################################################################
  ## Virtualisation
  #############################################################################
}
