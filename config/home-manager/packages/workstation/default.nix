{ ... }:

let
  files = builtins.removeAttrs (builtins.readDir ./.) [
    "default.nix"
    "brave-search-engines.sh"
  ];

  # Import all other .nix files as modules
  moduleFiles = builtins.map (fname: ./. + "/${fname}") (builtins.attrNames files);
in
{
  # Import all the package modules
  imports = moduleFiles;
}
