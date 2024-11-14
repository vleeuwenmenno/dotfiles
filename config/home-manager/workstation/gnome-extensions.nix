{
  config,
  pkgs-unstable,
  pkgs,
  ...
}:
{
  # We run most extensions from unstable because they are more up-to-date
  home.packages =
    with pkgs.gnomeExtensions;
    [
      user-themes
      weather-oclock
      native-window-placement
      kimpanel
    ]
    ++ (with pkgs-unstable.gnomeExtensions; [
      tiling-shell
      lilypad
      tailscale-qs
      gsconnect
      blur-my-shell
      space-bar
      gtk4-desktop-icons-ng-ding
      logo-menu
      media-controls
      burn-my-windows
      coverflow-alt-tab
      dash-to-dock
      appindicator
      autohide-battery
      battery-health-charging
      just-perfection
      smile-complementary-extension
      vitals
      clipboard-indicator
    ]);

  # Copy burn-my-windows profile to user config
  home.file.".config/burn-my-windows/profiles/default.conf".text = ''
    [burn-my-windows-profile]
    fire-enable-effect=false
    tv-glitch-enable-effect=true
    tv-glitch-animation-time=250
  '';

  dconf = {
    settings = {
      # vitals settings
      "org/gnome/shell/extensions/vitals" = {
        position-in-panel = 0;
        use-higher-precision = true;
        icon-style = 1;
      };

      # To get an ID of an extension, run `gnome-extensions list`
      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = [
          "kimpanel@kde.org"
          "lilypad@shendrew.github.io"
          "tilingshell@ferrarodomenico.com"
          "gsconnect@andyholmes.github.io"
          "blur-my-shell@aunetx"
          "tailscale@joaophi.github.com"
          "easy_docker_containers@red.software.systems"
          "weatheroclock@CleoMenezesJr.github.io"
          "space-bar@luchrioh"
          "gtk4-ding@smedius.gitlab.com"
          "logomenu@aryan_k"
          "mediacontrols@cliffniff.github.com"
          "burn-my-windows@schneegans.github.com"
          "CoverflowAltTab@palatis.blogspot.com"
          "dash-to-dock@micxgx.gmail.com"
          "gnome-shell-extension-appindicator"
          "appindicatorsupport@rgcjonas.gmail.com"
          "user-theme@gnome-shell-extensions.gcampax.github.com"
          "autohide-battery@sitnik.ru"
          "just-perfection-desktop@just-perfection"
          "native-window-placement@gnome-shell-extensions.gcampax.github.com"
          "smile-extension@mijorus.it"
          "Vitals@CoreCoding.com"
          "clipboard-indicator@tudmotu.com"
        ];
      };

      # Clipboard indicator settings
      "org/gnome/shell/extensions/clipboard-indicator" = {
        history-size = 50;
        cache-size = 50;
        preview-size = 50;
        strip-text = true;
        keep-selected-on-clear = true;
        toggle-menu = [ "<Shift><Alt>V" ];
      };

      # Perfection settings
      "org/gnome/shell/extensions/just-perfection" = {
        theme = false;
        notification-banner-position = 2;
        startup-status = 0;
      };

      # Autohide battery
      "org/gnome/shell/extensions/autohide-battery" = {
        hide-on = 95;
      };

      # Configure dash-to-dock
      "org/gnome/shell/extensions/dash-to-dock" = {
        pressure-threshold = 250;
        require-pressure-to-show = false;
        apply-custom-theme = false;
        apply-glossy-effect = false;
        autohide-in-fullscreen = true;
        background-opacity = 0.8;
        custom-theme-customize-running-dots = false;
        custom-theme-running-dots-border-color = "rgb(255,255,255)";
        custom-theme-running-dots-color = "rgb(255,255,255)";
        dash-max-icon-size = 48;
        dock-fixed = false;
        dock-position = "LEFT";
        extend-height = 0;
        height-fraction = 0.9;
        intellihide = true;
        intellihide-mode = "ALL_WINDOWS";
        multi-monitor = true;
        preferred-monitor = -2;
        preferred-monitor-by-connector = "DP-2";
        running-indicator-dominant-color = true;
        running-indicator-style = "DOTS";
        show-apps-at-top = true;
        show-favorites = true;
        show-mounts = false;
        show-trash = true;
        transparency = 0.75;
        transparency-mode = "FIXED";
        unity-backlit-items = false;
      };

      # Configure logo-menu
      "org/gnome/shell/extensions/Logo-menu" = {
        hide-icon-shadow = false;
        menu-button-extensions-app = "org.gnome.Extensions.desktop";
        menu-button-icon-image = 23;
        menu-button-icon-size = 24;
        menu-button-system-monitor = "missioncenter";
        show-power-options = false;
        symbolic-icon = true;
        use-custom-icon = false;
      };

      # Configure covereflow-alt-tab
      "org/gnome/shell/extensions/coverflowalttab" = {
        animation-time = 0.2;
        easing-function = "ease-out-quart";
        icon-has-shadow = true;
        icon-style = "Overlay";
        invert-swipes = false;
        position = "Top";
        switcher-looping-method = "Flip Stack";
        switcher-style = "Coverflow";
      };

      # Configure burn-my-windows
      "org/gnome/shell/extensions/burn-my-windows" = {
        active-profile = "${config.home.homeDirectory}/.config/burn-my-windows/profiles/default.conf";
      };

      # Configure blur-my-shell
      "org/gnome/shell/extensions/blur-my-shell" = {
        brightness = 0.75;
        noise-amount = 0;
      };

      # Configure tiling shell
      "org/gnome/shell/extensions/tilingshell" = {
        layouts-json = ''
          [
            {
              "id": "Landscape Ultrawide",
              "tiles": [
                { "x": 0, "y": 0, "width": 0.22, "height": 0.5, "groups": [1, 2] },
                { "x": 0, "y": 0.5, "width": 0.22, "height": 0.5, "groups": [1, 2] },
                { "x": 0.22, "y": 0, "width": 0.56, "height": 1, "groups": [2, 3] },
                { "x": 0.78, "y": 0, "width": 0.22, "height": 0.5, "groups": [3, 4] },
                { "x": 0.78, "y": 0.5, "width": 0.22, "height": 0.5, "groups": [3, 4] }
              ]
            },
            {
              "id": "Portrait Ultrawide",
              "tiles": [
                { "x": 0, "y": 0, "width": 1, "height": 0.25, "groups": [1] },
                { "x": 0, "y": 0.25, "width": 1, "height": 0.5, "groups": [1, 2] },
                { "x": 0, "y": 0.75, "width": 0.5, "height": 0.25, "groups": [2, 3] },
                { "x": 0.5, "y": 0.75, "width": 0.5, "height": 0.25, "groups": [2, 3] }
              ]
            },
            {
              "id": "Landscape Laptop",
              "tiles": [
                { "x": 0, "y": 0, "width": 0.33, "height": 0.5, "groups": [1, 2] },
                { "x": 0.33, "y": 0, "width": 0.67, "height": 1, "groups": [1] },
                { "x": 0, "y": 0.5, "width": 0.33, "height": 0.5, "groups": [2, 1] }
              ]
            },
            {
              "id": "Landscape Ultrawide Power-User",
              "tiles": [
                {
                  "x": 0,
                  "y": 0,
                  "width": 0.1984375,
                  "height": 0.5028409090909091,
                  "groups": [1, 2]
                },
                {
                  "x": 0.1984375,
                  "y": 0,
                  "width": 0.3015625,
                  "height": 1,
                  "groups": [4, 1]
                },
                {
                  "x": 0,
                  "y": 0.5028409090909091,
                  "width": 0.1984375,
                  "height": 0.49715909090909094,
                  "groups": [2, 1]
                },
                {
                  "x": 0.8015625,
                  "y": 0,
                  "width": 0.1984375,
                  "height": 1,
                  "groups": [3]
                },
                {
                  "x": 0.5,
                  "y": 0,
                  "width": 0.30156249999999996,
                  "height": 1,
                  "groups": [3, 4]
                }
              ]
            }
          ]
        '';
        overridden-settings = "{\"org.gnome.mutter.keybindings\":{\"toggle-tiled-right\":\"['<Super>Right']\",\"toggle-tiled-left\":\"['<Super>Left']\"},\"org.gnome.desktop.wm.keybindings\":{\"maximize\":\"['<Super>Up']\",\"unmaximize\":\"['<Super>Down', '<Alt>F5']\"},\"org.gnome.mutter\":{\"edge-tiling\":\"false\"}}";
      };

      # Configure forge
      "org/gnome/shell/extensions/forge" = {
        move-pointer-focus-enabled = false;
        stacked-tiling-mode-enabled = true;
        tabbed-tiling-mode-enabled = true;
        tiling-mode-enabled = true;
      };

      "org/gnome/shell/extensions/forge/keybindings" = {
        con-split-horizontal = [ "<Super>z" ];
        con-split-layout-toggle = [ "<Super>g" ];
        con-split-vertical = [ "<Super>v" ];
        con-stacked-layout-toggle = [ "<Shift><Super>s" ];
        con-tabbed-layout-toggle = [ "<Shift><Super>t" ];
        con-tabbed-showtab-decoration-toggle = [ "<Control><Alt>y" ];
        focus-border-toggle = [ "<Super>x" ];
        prefs-tiling-toggle = [ "<Super>w" ];
        window-focus-down = [ "<Super>j" ];
        window-focus-left = [ "<Super>h" ];
        window-focus-right = [ "<Super>l" ];
        window-focus-up = [ "<Super>k" ];
        window-gap-size-decrease = [ "<Control><Super>minus" ];
        window-gap-size-increase = [ "<Control><Super>plus" ];
        window-move-down = [ "<Shift><Super>j" ];
        window-move-left = [ "<Shift><Super>h" ];
        window-move-right = [ "<Shift><Super>l" ];
        window-move-up = [ "<Shift><Super>k" ];
        window-resize-bottom-decrease = [ "<Shift><Control><Super>i" ];
        window-resize-bottom-increase = [ "<Control><Super>u" ];
        window-resize-left-decrease = [ "<Shift><Control><Super>o" ];
        window-resize-left-increase = [ "<Control><Super>y" ];
        window-resize-right-decrease = [ "<Shift><Control><Super>y" ];
        window-resize-right-increase = [ "<Control><Super>o" ];
        window-resize-top-decrease = [ "<Shift><Control><Super>u" ];
        window-resize-top-increase = [ "<Control><Super>i" ];
        window-snap-center = [ "<Control><Alt>c" ];
        window-snap-one-third-left = [ "<Control><Alt>d" ];
        window-snap-one-third-right = [ "<Control><Alt>g" ];
        window-snap-two-third-left = [ "<Control><Alt>e" ];
        window-snap-two-third-right = [ ];
        window-swap-down = [ "<Control><Super>j" ];
        window-swap-last-active = [ "<Super>Return" ];
        window-swap-left = [ "<Control><Super>h" ];
        window-swap-right = [ "<Control><Super>l" ];
        window-swap-up = [ "<Control><Super>k" ];
        window-toggle-always-float = [ "<Shift><Super>c" ];
        window-toggle-float = [ "<Super>c" ];
        workspace-active-tile-toggle = [ "<Shift><Super>w" ];
      };

      # User theme
      "org/gnome/shell/extensions/user-theme" = {
        name = "Yaru-purple-dark";
      };
    };
  };
}
