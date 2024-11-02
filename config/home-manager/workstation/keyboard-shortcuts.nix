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
  };
}
