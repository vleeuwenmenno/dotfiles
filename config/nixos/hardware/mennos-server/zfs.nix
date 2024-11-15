{ config, pkgs, ... }:
{
  # Enable ZFS support
  boot.supportedFilesystems = [ "zfs" ];

  # ZFS system services
  services.zfs = {
    autoScrub = {
      enable = true;
      interval = "weekly";
    };
  };

  # Install ZFS utilities
  environment.systemPackages = with pkgs; [
    zfs
    zfstools
  ];

  # If you want to keep compression settings
  boot.kernelParams = [ "zfs.zfs_compressed_arc_enabled=1" ];

  fileSystems = {
    "/mnt/ai" = {
      device = "datapool/ai";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };
    "/mnt/astrophotography" = {
      device = "datapool/astro";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };
    "/mnt/audiobooks" = {
      device = "datapool/audiobooks";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };
    "/mnt/downloads" = {
      device = "datapool/downloads";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };
    "/mnt/ISOs" = {
      device = "datapool/isos";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };
    "/mnt/movies" = {
      device = "datapool/movies";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };
    "/mnt/music" = {
      device = "datapool/music";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };
    "/mnt/old_backups" = {
      device = "datapool/old_backups";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };
    "/mnt/photos" = {
      device = "datapool/photos";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };
    "/mnt/services" = {
      device = "datapool/services";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };
    "/mnt/stash" = {
      device = "datapool/stash";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };
    "/mnt/tvshows" = {
      device = "datapool/tv_shows";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };
    "/mnt/VMs" = {
      device = "datapool/vms";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };
  };
}
