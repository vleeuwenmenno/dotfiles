{
  config,
  isServer ? false,
  ...
}:

{
  programs.home-manager.enable = true;

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = pkg: true;
  };

  imports =
    [ ./packages/common/default.nix ]
    ++ (
      if isServer then
        [
          ./packages/server/default.nix
          ./server/default.nix
        ]
      else
        [
          ./packages/workstation/default.nix
          ./workstation/default.nix
        ]
    );

  home = {
    username = "menno";
    homeDirectory = "/home/menno";
    stateVersion = "24.05";
    sessionVariables = {
      PATH = "${config.home.homeDirectory}/go/bin:$PATH"; # Removed extra asterisks
    };
  };
}
