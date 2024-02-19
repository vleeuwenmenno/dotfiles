{ config, pkgs, ... }:
{
  home = {
    username = "menno";
    homeDirectory = "/home/menno";
    stateVersion = "23.11";

    packages = [
      pkgs.gnumake
      pkgs.btop
      pkgs.go
    ];
  };

  programs = {
    home-manager.enable = true;

    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };

    git = {
      enable = true;
      userName = "Menno van Leeuwen";
      userEmail = "menno@vleeuwen.me";
    };
    # nushell.enable = true;
  };
}