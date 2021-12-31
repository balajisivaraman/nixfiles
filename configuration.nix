{
  imports = [
    ./common.nix
    ./host/configuration.nix
    ./host/hardware.nix
    ./fonts/otf-san-francisco/configuration.nix
    ./programs/i3lockr/configuration.nix
    ./services/change-wallpaper.nix
    ./services/update-commodity-prices.nix
    ./services/hledger-to-influxdb.nix
    ./services/nextcloud-client.nix
    ./services/thunderbird.nix
    ./services/zotero.nix
 ];
}
