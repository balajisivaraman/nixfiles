{ config, pkgs, options, ... }:

{
  #############################################################################
  ## System Configuration
  #############################################################################

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05";

  # Only keep the last 500MiB of systemd journal.
  services.journald.extraConfig = "SystemMaxUse=500M";

  # Collect nix store garbage and optimise daily.
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 30d";
  nix.optimise.automatic = true;

  # Upgrade packages and reboot if needed
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;
  system.autoUpgrade.channel = https://nixos.org/channels/nixos-unstable;
  system.autoUpgrade.dates = "06:45";

  #############################################################################
  ## Locale Configuration
  #############################################################################

  # Set your time zone.
  services.timesyncd = {
    enable = true;
    servers = [
      "0.in.pool.ntp.org"
      "1.in.pool.ntp.org"
      "2.in.pool.ntp.org"
      "3.in.pool.ntp.org"
    ];
  };
  time.timeZone = "Asia/Kolkata";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_IN.UTF-8";

  #############################################################################
  ## Networking
  #############################################################################

  # Enable the firewall
  networking.firewall.enable = true;
  # Ping is enabled
  networking.firewall.allowPing = true;

  #############################################################################
  ## Package Management
  #############################################################################

  # gnupg doesn't come with pinentry, so require the agent
  programs.gnupg.agent.enable = true;
  # enable fish shell
  programs.fish.enable = true;
  # Enable the SSH Agent.
  programs.ssh.startAgent = true;
  # Allow packages with non-free licenses.
  nixpkgs.config.allowUnfree = true;

  # Packages common to all machines
  environment.systemPackages = with pkgs; [
    autojump
    bat
    fd
    fzf
    git
    gnumake
    gnupg
    gnutls
    htop
    killall
    man-pages
    neovim
    python3
    ripgrep
    rsync
    stow
    tmux
    unzip
    vim
    wget
    which
  ];

  #############################################################################
  ## User accounts
  #############################################################################

  # Enable passwd and co.
  users.mutableUsers = true;

  # My default user account on machines
  users.extraUsers.balaji = {
    uid = 1000;
    description = "Balaji Sivaraman <balaji@balajisivaraman.com>";
    isNormalUser = true;
    extraGroups = [ "audio" "wheel" ];
    group = "users";
    initialPassword = "breadbread";
    shell = "/run/current-system/sw/bin/fish";
  };
}
