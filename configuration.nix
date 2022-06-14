{
  imports = [
    ./common.nix
    ./host/configuration.nix
    ./host/hardware.nix
    ./fonts/otf-san-francisco/configuration.nix
    ./programs/emacs.nix
    ./programs/i3lockr/configuration.nix
    ./services/change-wallpaper.nix
    ./services/update-commodity-prices.nix
    ./services/hledger-to-influxdb.nix
    ./services/nextcloud-client.nix
    ./services/udevmon.nix
    ./services/zotero.nix
 ];
}
