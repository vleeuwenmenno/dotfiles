{
  config,
  lib,
  pkgs,
  ...
}:

{
  environment.systemPackages = [ (pkgs.callPackage ./pano { }) ];
}
