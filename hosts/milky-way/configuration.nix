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

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
      experimental-features = nix-command flakes
    '';
  };

  environment.pathsToLink = [
    "/share/nix-direnv"
  ];

  #############################################################################
  ## Font Configuration
  #############################################################################

  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      (nerdfonts.override { fonts = [ "Terminus" ]; })
    ];
    fontconfig = {
      antialias = true;
      hinting.enable = true;
      subpixel = {
        rgba = "rgb";
        lcdfilter = "default";
      };
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "SF Pro Text" ];
        monospace = [ "NotoSansMono Nerd Font" ];
      };
    };
  };

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
      defaultSession = "none+xmonad";
    };
    windowManager.i3 = {
      package = pkgs.i3-gaps;
      enable = true;
    };
    windowManager.xmonad = {
      enable = true;
      extraPackages = haskellPackages: [
        haskellPackages.xmonad-contrib_0_17_0
        haskellPackages.xmonad-extras_0_17_0
      ];
      config = pkgs.lib.readFile ./xmonad-config.hs;
    };
  };

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.balaji.enableGnomeKeyring = true;

  # Enable nvidia graphics
  services.xserver.videoDrivers = [ "nvidia" ];

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  #############################################################################
  ## Package Management
  #############################################################################

  fonts.otf-san-francisco.enable = true;
  programs.gnupg.agent.pinentryFlavor = "qt";
  programs.i3lockr.enable = true;

  services.change-wallpaper.enable = true;
  services.clipcat.enable = true;
  services.emacs.package = pkgs.emacsPgtkGcc;
  services.emacs.enable = true;
  services.gvfs.enable = true;
  services.nextcloud-client.enable = true;
  services.pcscd.enable = true;
  services.thunderbird.enable = false;
  services.udev.packages = [ pkgs.yubikey-personalization ];
  services.zotero.enable = false;
  services.influxdb.enable = true;
  services.grafana.enable = true;

  nixpkgs.overlays =
  let
    # Change this to a rev sha to pin
    moz-rev = "master";
    moz-url = builtins.fetchTarball { url = "https://github.com/mozilla/nixpkgs-mozilla/archive/${moz-rev}.tar.gz";};
    nightlyOverlay = (import "${moz-url}/firefox-overlay.nix");
  in [
    (import "${fetchTarball "https://github.com/nix-community/fenix/archive/main.tar.gz"}/overlay.nix")
    (self: super: { nix-direnv = super.nix-direnv.override { enableFlakes = true; }; } )
    (import (builtins.fetchGit {
      url = "https://github.com/nix-community/emacs-overlay.git";
      ref = "master";
      rev = "555de7d00eb7c8df21242fdad6f3a6f2201e7e14"; # change the revision
    }))
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
        audacity
        binutils
        cantata
        delta
        direnv
        dunst
        emacsPgtkGcc
        feh
        (fenix.stable.withComponents [
          "cargo"
          "clippy"
          "rust-src"
          "rustc"
          "rustfmt"
        ])
        flameshot
        gcc
        gimp
        go
        google-chrome
        gopls
        gparted
        hledger
        imagemagick
        influxdb
        jmtpfs
        keepassxc
        latest.firefox-nightly-bin
        libnotify
        libreoffice-fresh
        libsecret
        lm_sensors
        lxsession
        nextcloud-client
        nix-direnv
        nodejs-16_x
        nordic
        obinskit
        pamixer
        pavucontrol
        pcmanfm
        picom
        polybar
        libsForQt5.qtkeychain
        rofi
        rust-analyzer
        sqlite
        stalonetray
        thunderbird
        tree-sitter
        udiskie
        vlc
        xcape
        xmobar
        xorg.xmodmap
        xss-lock
        youtube-dl
        yubikey-manager
        yubikey-manager-qt
        yubikey-personalization-gui
        yubioath-desktop
        zathura
        zotero
      ];

  environment.variables = {
    "RUST_SRC_PATH" = "${pkgs.fenix.stable.rust-src}/bin/rust-lib/src";
  };

  #############################################################################
  ## Virtualisation
  #############################################################################
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
    };
  };
}
