{ config, pkgs, ... }:
{
  imports = [
    ./packages/vscode.nix
    ./packages/go.nix
    ./packages/kitty.nix
    ./packages/zed-editor.nix
    ./fonts.nix
    ./gnome-extensions.nix
    ./dconf.nix
    ./keyboard-shortcuts.nix
    ./virtualization.nix
    ./packages.nix
  ];

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = pkg: true;
  };

  home.username = "menno";
  home.homeDirectory = "/home/menno";
  home.stateVersion = "24.05";

  home.sessionVariables = {
    PATH = "${config.home.homeDirectory}/go/bin:$PATH";
  };
}
