{ config, pkgs, ... }:
let
  pinnedPkgs = import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/41dea55321e5a999b17033296ac05fe8a8b5a257.tar.gz";
    # Update this SHA256 when a new version is required ^^^
    # You can find them here: https://www.nixhub.io/packages/zed-editor
  }) { };
in
{
  # Add zed-editor to your home packages
  home.packages = [
    pinnedPkgs.zed-editor
  ];
}
