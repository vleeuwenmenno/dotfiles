{ pkgs, ... }:
{
    programs.kitty = {
      enable = true;
      font = {
        name = "Hack Nerd Font";
        size = 14;
      };

      settings = {
        dynamic_background_opacity = true;
        background_opacity = "0.95";
        background_blur = 64;
      };

      
      shellIntegration.enableFishIntegration = true;
      theme = "Catppuccin-Macchiato";
      #Also available: Catppuccin-Frappe Catppuccin-Latte Catppuccin-Macchiato Catppuccin-Mocha
      # See all available kitty themes at: https://github.com/kovidgoyal/kitty-themes/blob/46d9dfe230f315a6a0c62f4687f6b3da20fd05e4/themes.json
    };
}