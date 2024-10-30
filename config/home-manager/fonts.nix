{ pkgs, ... }:
{
    fonts.fontconfig.enable = true;
    home.packages = [
        (pkgs.nerdfonts.override { fonts = [ "Hack" "FiraCode" "Meslo" "FiraCode" "DroidSansMono" ]; })
    ];
}