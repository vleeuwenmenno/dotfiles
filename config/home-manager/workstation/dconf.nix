{ config, pkgs, ... }:
{
  # GTK Theme
  gtk = {
    enable = true;

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    theme = {
      name = "Yaru-purple-dark";
      package = pkgs.yaru-theme;
    };

    cursorTheme = {
      name = "Numix-Cursor";
      package = pkgs.numix-cursor-theme;
    };

    gtk3.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };

    gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
  };

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };

      # Pinned apps
      # add more by listing them with `gsettings list-recursively | grep favorite-apps`
      "org/gnome/shell" = {
        favorite-apps = [
          "io.github.zen_browser.zen.desktop"
          "code.desktop"
          "org.telegram.desktop.desktop"
          "spotify.desktop"
          "vesktop.desktop"
          "org.gnome.Geary.desktop"
          "org.gnome.Nautilus.desktop"
          "org.gnome.Console.desktop"
        ];
      };

      # GNOME Terminal settings
      "org/gnome/Console" = {
        use-system-font = false;
        custom-font = "Hack Nerd Font 14";
        theme = "night";
      };

      # Set wallpaper
      "org/gnome/desktop/background" = {
        picture-uri-dark = "file:///${config.home.homeDirectory}/dotfiles/secrets/wp/9.png";
        picture-uri = "file:///${config.home.homeDirectory}/dotfiles/secrets/wp/9.png";
        picture-options = "zoom";
        primary-color = "#000000";
      };
    };
  };

}
