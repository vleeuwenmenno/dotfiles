{ pkgs, ... }: 
{
  dconf.settings = {
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminal/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/1password-quick-access/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/screenshot/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/missioncenter/"
        ];
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminal" = {
        binding = "<Primary><Alt>t";
        command = "kitty";
        name = "open-terminal";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/1password-quick-access" = {
        binding = "<Ctrl><Alt>space";
        command = "1password --quick-access";
        name = "1password-quick-access";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/screenshot" = {
        binding = "<Shift><Alt>4";
        command = "flameshot gui";
        name = "screenshot";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/missioncenter" = {
        binding = "<Ctrl><Shift>Escape";
        command = "missioncenter";
        name = "missioncenter";
    };
  };
}
