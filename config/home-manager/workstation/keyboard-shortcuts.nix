{ pkgs, ... }:
{
  dconf.settings = {
    "org/gnome/shell/keybindings" = {
      show-screenshot-ui = [
        "Print"
        "<Shift><Alt>4"
      ];
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/1password-quick-access/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/missioncenter/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminal/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/emotes/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/frog/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ulauncher/"
      ];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/1password-quick-access" = {
      binding = "<Ctrl><Alt>space";
      command = "1password --quick-access";
      name = "1password-quick-access";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/missioncenter" = {
      binding = "<Ctrl><Shift>Escape";
      command = "missioncenter";
      name = "missioncenter";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminal" = {
      binding = "<Ctrl><Alt>t";
      command = "kgx";
      name = "terminal";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/emotes" = {
      binding = "<Super>e";
      command = "smile";
      name = "emotes";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/frog" = {
      binding = "<Shift><Alt>3";
      command = "frog";
      name = "frog-ocr";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ulauncher" = {
      binding = "<Control>Space";
      command = "ulauncher-toggle";
      name = "ulauncher";
    };
  };
}
