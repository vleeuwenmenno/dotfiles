{
  config,
  pkgs,
  lib,
  ...
}:

let
  # Initial configuration files
  settingsJson = builtins.toJSON {
    blacklisted-desktop-dirs = "/usr/share/locale:/usr/share/app-install:/usr/share/kservices5:/usr/share/fk5:/usr/share/kservicetypes5:/usr/share/applications/screensavers:/usr/share/kde4:/usr/share/mimelnk";
    clear-previous-query = true;
    disable-desktop-filters = false;
    grab-mouse-pointer = false;
    hotkey-show-app = "<Control>Space";
    render-on-screen = "mouse-pointer-monitor";
    show-indicator-icon = true;
    show-recent-apps = "4";
    terminal-command = "kgx";
    theme-name = "dark";
  };

  shortcutsJson = builtins.toJSON {
    "0bab9d26-5464-4501-bc95-9995d8fa1405" = {
      "id" = "0bab9d26-5464-4501-bc95-9995d8fa1405";
      "name" = "Google Search";
      "keyword" = "g";
      "cmd" = "https://google.com/search?q=%s";
      "icon" = "/nix/store/ifh4wl3j3cv7f6b5rdzqcnhw5sa27pg9-ulauncher-5.15.7/share/ulauncher/media/google-search-icon.png";
      "is_default_search" = true;
      "run_without_argument" = false;
      "added" = 0;
    };
    "d72834d1-5d81-4f5d-a9f6-386b12110f56" = {
      "id" = "d72834d1-5d81-4f5d-a9f6-386b12110f56";
      "name" = "Stack Overflow";
      "keyword" = "so";
      "cmd" = "https://stackoverflow.com/search?q=%s";
      "icon" = "/nix/store/ifh4wl3j3cv7f6b5rdzqcnhw5sa27pg9-ulauncher-5.15.7/share/ulauncher/media/stackoverflow-icon.svg";
      "is_default_search" = true;
      "run_without_argument" = false;
      "added" = 0;
    };
    "4dfcffeb-879c-49b2-83bb-c16254a7ce75" = {
      "id" = "4dfcffeb-879c-49b2-83bb-c16254a7ce75";
      "name" = "GoLink";
      "keyword" = "go";
      "cmd" = "http://go/%s";
      "icon" = null;
      "is_default_search" = false;
      "run_without_argument" = false;
      "added" = 0;
    };
    "40d1ed32-8fd3-4bf8-92f5-cbaa7cd607a1" = {
      "id" = "40d1ed32-8fd3-4bf8-92f5-cbaa7cd607a1";
      "name" = "NixOS";
      "keyword" = "nix";
      "cmd" = "https://search.nixos.org/packages?query=%s";
      "icon" = null;
      "is_default_search" = false;
      "run_without_argument" = false;
      "added" = 0;
    };
    "43d1ed32-8fd3-fbf8-94f5-cffa7cd607a1" = {
      "id" = "40d1ed32-8fd3-4bf8-92f5-cbaa7cd607a1";
      "name" = "GitHub";
      "keyword" = "gh";
      "cmd" = "https://github.com/search?q=%s";
      "icon" = null;
      "is_default_search" = false;
      "run_without_argument" = false;
      "added" = 0;
    };
  };

  # Create a Python environment with all required packages
  pythonWithPackages = pkgs.python3.withPackages (
    ps: with ps; [
      pytz
      thefuzz
      tornado
      docker
      requests
      pint
      simpleeval
      parsedatetime
      fuzzywuzzy
    ]
  );

  # Desktop file content with GDK_BACKEND=x11
  desktopEntry = ''
    [Desktop Entry]
    Name=Ulauncher
    Comment=Application launcher for Linux
    Categories=GNOME;Utility;
    Exec=env GDK_BACKEND=x11 ${config.home.homeDirectory}/.local/bin/ulauncher-wrapped
    Icon=ulauncher
    Terminal=false
    Type=Application
  '';

in

# Extensions
# https://github.com/friday/ulauncher-gnome-settings
# https://ext.ulauncher.io/-/github-ulauncher-ulauncher-emoji
# https://ext.ulauncher.io/-/github-tchar-ulauncher-albert-calculate-anything
# https://ext.ulauncher.io/-/github-isacikgoz-ukill
# https://ext.ulauncher.io/-/github-iboyperson-ulauncher-system
{
  nixpkgs.overlays = [
    (final: prev: { ulauncher = prev.ulauncher.override { python3 = pythonWithPackages; }; })
  ];

  home.packages = with pkgs; [
    ulauncher
    pythonWithPackages # Make Python environment available system-wide
  ];

  # Create a wrapper script to set PYTHONPATH and GDK_BACKEND=x11
  home.file.".local/bin/ulauncher-wrapped" = {
    executable = true;
    text = ''
      #!${pkgs.bash}/bin/bash
      export GDK_BACKEND=x11
      export PYTHONPATH="${pythonWithPackages}/${pythonWithPackages.sitePackages}:$PYTHONPATH"
      exec ${pkgs.ulauncher}/bin/ulauncher "$@"
    '';
  };

  # Update both desktop files
  xdg.configFile."autostart/ulauncher.desktop".text = desktopEntry;
  xdg.dataFile."applications/ulauncher.desktop".text = desktopEntry;

  # Enable autostart for Ulauncher
  xdg.configFile."autostart/ulauncher.desktop".source = "${pkgs.ulauncher}/share/applications/ulauncher.desktop";

  # Overwrite ulauncher settings and shortcuts
  home.activation.ulauncher-config = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    config_dir="$HOME/.config/ulauncher"
    mkdir -p "$config_dir"

    rm -f "$config_dir/settings.json"
    echo '${settingsJson}' > "$config_dir/settings.json"
    rm -f "$config_dir/shortcuts.json"
    echo '${shortcutsJson}' > "$config_dir/shortcuts.json"
  '';
}
