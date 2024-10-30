{ config, pkgs, ... }: {
  imports = [
    ./vscode.nix
    ./fonts.nix
    ./kitty.nix
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
  home.file = { };

  home.sessionVariables = {
    GOROOT = "${pkgs.go}/share/go";
    GOPATH = "${config.home.homeDirectory}/go";
    PATH = "${config.home.homeDirectory}/go/bin:$PATH";
  };
}
