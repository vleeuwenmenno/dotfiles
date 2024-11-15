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
    };
    "/mnt/astrophotography" = {
      device = "datapool/astro";
      fsType = "zfs";
    };
    "/mnt/audiobooks" = {
      device = "datapool/audiobooks";
      fsType = "zfs";
    };
    "/mnt/downloads" = {
      device = "datapool/downloads";
      fsType = "zfs";
    };
    "/mnt/ISOs" = {
      device = "datapool/isos";
      fsType = "zfs";
    };
    "/mnt/movies" = {
      device = "datapool/movies";
      fsType = "zfs";
    };
    "/mnt/music" = {
      device = "datapool/music";
      fsType = "zfs";
    };
    "/mnt/old_backups" = {
      device = "datapool/old_backups";
      fsType = "zfs";
    };
    "/mnt/photos" = {
      device = "datapool/photos";
      fsType = "zfs";
    };
    "/mnt/services" = {
      device = "datapool/services";
      fsType = "zfs";
    };
    "/mnt/stash" = {
      device = "datapool/stash";
      fsType = "zfs";
    };
    "/mnt/tvshows" = {
      device = "datapool/tv_shows";
      fsType = "zfs";
    };
    "/mnt/VMs" = {
      device = "datapool/vms";
      fsType = "zfs";
    };
  };
}
