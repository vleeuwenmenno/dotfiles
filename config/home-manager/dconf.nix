{ config, pkgs, ... }:
{
  dconf = {
    enable = true;
    settings = {
      # Set the color scheme to dark
      "org/gnome/desktop/interface".color-scheme = "prefer-dark";

      # Pinned apps
      # add more by listing them with `gsettings list-recursively | grep favorite-apps`
      "org/gnome/shell" = {
        favorite-apps = [
          "io.github.zen_browser.zen.desktop"
          "code.desktop"
          "org.telegram.desktop.desktop"
          "spotify.desktop"
          "vesktop.desktop"
          "kitty.desktop"
          "org.gnome.Geary.desktop"
        ];
      };

      # Set wallpaper
      "org/gnome/desktop/background" = {
        picture-uri-dark = "file:///${config.home.homeDirectory}/dotfiles/secrets/wp/9.jpg";
        picture-uri = "file:///${config.home.homeDirectory}/dotfiles/secrets/wp/9.jpg";
        picture-options = "zoom";
        primary-color = "#000000";
      };
    };
  };

}
