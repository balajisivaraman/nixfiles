{ config, pkgs, options, ... }:

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

  systemd.timers.change-wallpaper = {
    description = "Set my wallpaper using feh on boot and in 30 minute intervals";
    wantedBy = [ "timers.target" ];
    after = [ "graphical.target" ];
    timerConfig = {
      OnActiveSec = "2";
      OnUnitActiveSec = "30min";
    };
  };
  systemd.services.change-wallpaper = {
    description = "Change Wallpaper";
    serviceConfig = {
      Type = "simple";
      Environment = "DISPLAY=:0";
      ExecStart = "${pkgs.feh}/bin/feh --bg-fill --randomize /media/backup/Nextcloud/Wallpapers";
      User = "balaji";
      Group = "users";
    };
  };

  #############################################################################
  ## Package Management
  #############################################################################

  services.emacs.package = pkgs.emacsPgtkGcc;
  programs.gnupg.agent.pinentryFlavor = "qt";

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
    delta
    dunst
    emacsPgtkGcc
    feh
    flameshot
    gimp
    google-chrome
    gparted
    imagemagick
    keepassxc
    latest.firefox-nightly-bin
    libnotify
    lxsession
    nextcloud-client
    picom
    polybar
    rofi
    starship
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
