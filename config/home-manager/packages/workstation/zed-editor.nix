{ pkgs-unstable, ... }:
{
  home.packages = with pkgs-unstable; [
    zed-editor
    nixd
    nixdoc

    # We need nodejs due to a stupid bug with CoPilot not loading properly
    # https://github.com/zed-industries/zed/issues/12187#issuecomment-2322338504
    nodejs_22
  ];
}
