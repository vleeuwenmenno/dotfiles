{ ... }:
{
  imports = [
    ./minecraft.nix
    ./wireguard.nix
    ./torrent.nix
    ./stash.nix
    ./sabnzbd.nix
    ./gitea.nix
    ./golink.nix
    ./plex.nix
  ];
}
# TODO: Import all the package modules, disabled for testing one by one.
# { config, pkgs, ... }:

# let
#   files = builtins.removeAttrs (builtins.readDir ./.) [ "default.nix" ];

#   # Import all other .nix files as modules
#   moduleFiles = builtins.map (fname: ./. + "/${fname}") (builtins.attrNames files);
# in
# {
#   # Import all the package modules
#   imports = moduleFiles;
# }
