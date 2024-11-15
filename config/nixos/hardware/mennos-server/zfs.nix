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
    autoMount = true;
    pools.datapool = {
      import = true;
    };
    pools.backup = {
      import = true;
    };
  };

  # Install ZFS utilities
  environment.systemPackages = with pkgs; [
    zfs
    zfstools
  ];

  # If you want to keep compression settings
  boot.kernelParams = [ "zfs.zfs_compressed_arc_enabled=1" ];
}
