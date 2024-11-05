{ config, pkgs, ... }:
{
  # Import all the package modules
  imports = [
    ./1password.nix
    ./flatpak.nix
    ./steam.nix
    ./pano.nix
  ];
}
