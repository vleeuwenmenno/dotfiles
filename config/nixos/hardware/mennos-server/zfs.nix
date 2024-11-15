{ config, pkgs, ... }:
{ config, pkgs, ... }:

let
  # Create a script to set permissions
  permissionsScript = pkgs.writeShellScriptBin "set-zfs-permissions" ''
    # Set default permissions for all service directories
    find /mnt/services -mindepth 1 -maxdepth 1 -type d \
      -exec chmod 775 {} \; \
      -exec chown menno:users {} \;

    # Special cases
    chmod 774 /mnt/services/golink
    chown 65532:users /mnt/services/golink

    chmod 754 /mnt/services/torrent
    chown menno:users /mnt/services/torrent

    chmod 755 /mnt/services/proxy
    chmod 755 /mnt/services/static-websites

    # Set permissions for other mount points
    for dir in /mnt/{ai,astrophotography,audiobooks,downloads,ISOs,movies,music,old_backups,photos,stash,tvshows,VMs}; do
      chmod 755 "$dir"
      chown menno:users "$dir"
    done
  '';
in
{
  environment.systemPackages = with pkgs; [
    zfs
    zfstools
    permissionsScript
  ];

  # Add the permissions service
  systemd.services.zfs-permissions = {
    description = "Set ZFS mount permissions";

    # Run after ZFS mounts are available
    after = [ "zfs.target" ];
    requires = [ "zfs.target" ];

    # Run on boot and every 6 hours
    startAt = "*-*-* */6:00:00";

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${permissionsScript}/bin/set-zfs-permissions";
      User = "root";
      Group = "root";
    };
  };

  # Enable ZFS support
  boot.supportedFilesystems = [ "zfs" ];

  # ZFS system services
  services.zfs = {
    autoScrub = {
      enable = true;
      interval = "weekly";
    };
  };

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
