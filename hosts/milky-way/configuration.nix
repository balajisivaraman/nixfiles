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
        monospace = [ "PragmataPro Nerd Font" ];
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
      defaultSession = "none+i3";
    };
    windowManager.i3 = {
      package = pkgs.i3-gaps;
      enable = true;
    };
  };

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.gdm.enableGnomeKeyring = true;
  security.sudo.wheelNeedsPassword = false;

  # Enable nvidia graphics
  services.xserver.videoDrivers = [ "nvidia" ];

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  #############################################################################
  ## Package Management
  #############################################################################

  fonts.otf-san-francisco.enable = true;
  programs.gnupg.agent.pinentryFlavor = "gtk2";
  programs.i3lockr.enable = true;
  programs.emacs.enable = true;

  services.change-wallpaper.enable = true;
  services.clipcat.enable = true;
  services.gvfs.enable = true;
  services.nextcloud-client.enable = true;
  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];
  services.udevmon.enable = true;
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
    nightlyOverlay
  ];

  environment.systemPackages = with pkgs;
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
      i3status-rust
      imagemagick
      influxdb
      interception-tools
      interception-tools-plugins.dual-function-keys
      jmtpfs
      keepassxc
      latest.firefox-nightly-bin
      libnotify
      libreoffice-fresh
      libsecret
      lm_sensors
      lxsession
      perl534Packages.FileMimeInfo
      nextcloud-client
      nix-direnv
      nodejs-18_x
      nordic
      obinskit
      pamixer
      pavucontrol
      pcmanfm
      picom
      pinentry-gtk2
      libsForQt5.qtkeychain
      rofi
      rust-analyzer
      signal-desktop
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
