{ config, pkgs, ... }:
let
  pinnedPkgs = import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/d4f247e89f6e10120f911e2e2d2254a050d0f732.tar.gz";
    # Update this SHA256 when a new version is required ^^^
    # You can find them here: https://www.nixhub.io/packages/vscode
  }) { };
in
{
  # Use the pinned Go for the programs configuration
  programs.go = {
    enable = true;
    package = pinnedPkgs.go;
  };
}