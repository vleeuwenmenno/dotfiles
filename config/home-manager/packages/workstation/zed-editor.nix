{
  config,
  pkgs,
  pkgs-zed,
  ...
}:
{
  home.packages = [ pkgs-zed.zed-editor ];
}
