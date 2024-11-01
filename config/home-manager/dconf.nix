{ pkgs, ... }:
{
  dconf = {
    enable = true;
    settings = {
      # Set the color scheme to dark
      "org/gnome/desktop/interface".color-scheme = "prefer-dark";
    };
  };

}
