{ pkgs-unstable, pkgs, ... }:
{
  home.packages = with pkgs; [
    # GUI Application
    ## Utilities
    pkgs-unstable.mission-center # Task Manager like Windows 11
    gnome.gnome-tweaks
    pinta # Paint.NET alternative
    bottles # Wine manager
    trayscale # Tray icon for Tailscale
    spacedrive # Virtual filesystem manager
    smile # Emoji picker

    ## Chat Apps
    telegram-desktop
    betterdiscordctl
    vesktop
    whatsapp-for-linux
    signal-desktop

    ## Multimedia
    spotify
    plex-media-player
    vlc

    ## Astronomy
    stellarium

    ## Games
    ### Open-source games
    openra
    xonotic
    mindustry
    wesnoth
    shattered-pixel-dungeon

    ### Games launchers
    lutris
    heroic

    ### Game utilities
    protonup-qt
    protontricks

    ### Virtualization
    virt-manager
    virt-viewer
  ];
}
