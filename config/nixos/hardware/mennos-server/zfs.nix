{ config, pkgs, ... }:
{
  # Enable ZFS support
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.enableUnstable = false;

  # ZFS system services
  services.zfs = {
    autoSnapshot = {
      enable = true;
      frequent = 4; # Keep 4 15-minute snapshots
      hourly = 24; # Keep 24 hourly snapshots
      daily = 7; # Keep 7 daily snapshots
      weekly = 4; # Keep 4 weekly snapshots
      monthly = 12; # Keep 12 monthly snapshots
    };
    autoScrub = {
      enable = true;
      interval = "weekly"; # Scrub pools weekly
    };
  };

  # Your ZFS pool and datasets will be automatically imported
  # But we can specify mount points explicitly for clarity
  fileSystems = {
    "/mnt/20tb/Movies" = {
      device = "datapool/movies";
      fsType = "zfs";
      options = [ "defaults" ];
    };
    "/mnt/20tb/TV_Shows" = {
      device = "datapool/tv_shows";
      fsType = "zfs";
      options = [ "defaults" ];
    };
    "/mnt/20tb/Music" = {
      device = "datapool/music";
      fsType = "zfs";
      options = [ "defaults" ];
    };
    "/mnt/20tb/Astrophotography" = {
      device = "datapool/astro";
      fsType = "zfs";
      options = [ "defaults" ];
    };
    "/mnt/20tb/Downloads" = {
      device = "datapool/downloads";
      fsType = "zfs";
      options = [ "defaults" ];
    };
    "/mnt/20tb/Photos" = {
      device = "datapool/photos";
      fsType = "zfs";
      options = [ "defaults" ];
    };
    "/mnt/20tb/Stash" = {
      device = "datapool/stash";
      fsType = "zfs";
      options = [ "defaults" ];
    };
    "/mnt/20tb/ISOs" = {
      device = "datapool/isos";
      fsType = "zfs";
      options = [ "defaults" ];
    };
    "/mnt/20tb/Audiobooks" = {
      device = "datapool/audiobooks";
      fsType = "zfs";
      options = [ "defaults" ];
    };
    "/mnt/20tb/VMs" = {
      device = "datapool/vms";
      fsType = "zfs";
      options = [ "defaults" ];
    };
    "/mnt/20tb/Old_Backups" = {
      device = "datapool/old_backups";
      fsType = "zfs";
      options = [ "defaults" ];
    };
    "/mnt/20tb/Services" = {
      device = "datapool/services";
      fsType = "zfs";
      options = [ "defaults" ];
    };
  };

  # Install ZFS utilities
  environment.systemPackages = with pkgs; [
    zfs
    zfstools
  ];

  # If you want to keep compression settings
  boot.kernelParams = [ "zfs.zfs_compressed_arc_enabled=1" ];

  systemd.services.zfs-permissions = {
    description = "Set correct permissions on ZFS datasets";
    after = [ "zfs-mount.service" ];
    wantedBy = [ "multi-user.target" ];
    script = ''
      # Set ownership and permissions for each dataset
      # Astrophotography - menno:menno 770
      zfs set acltype=posixacl datapool/astro
      zfs set xattr=sa datapool/astro
      chown menno:menno /mnt/20tb/Astrophotography
      chmod 770 /mnt/20tb/Astrophotography

      # Audiobooks - menno:users 760
      zfs set acltype=posixacl datapool/audiobooks
      zfs set xattr=sa datapool/audiobooks
      chown menno:users /mnt/20tb/Audiobooks
      chmod 760 /mnt/20tb/Audiobooks

      # Downloads - menno:users 760
      chown menno:users /mnt/20tb/Downloads
      chmod 760 /mnt/20tb/Downloads

      # ISOs - menno:libvirt 777
      chown menno:libvirt /mnt/20tb/ISOs
      chmod 777 /mnt/20tb/ISOs

      # VMs - menno:libvirt 777
      chown menno:libvirt /mnt/20tb/VMs
      chmod 777 /mnt/20tb/VMs

      # Movies - menno:users 760
      chown menno:users /mnt/20tb/Movies
      chmod 760 /mnt/20tb/Movies

      # Music - menno:users 760
      chown menno:users /mnt/20tb/Music
      chmod 760 /mnt/20tb/Music

      # Old_Backups - menno:users 760
      chown menno:users /mnt/20tb/Old_Backups
      chmod 760 /mnt/20tb/Old_Backups

      # Photos - menno:menno 775
      chown menno:menno /mnt/20tb/Photos
      chmod 775 /mnt/20tb/Photos

      # Services - menno:users 760
      chown menno:users /mnt/20tb/Services
      chmod 760 /mnt/20tb/Services

      # Stash - menno:menno 775
      chown menno:menno /mnt/20tb/Stash
      chmod 775 /mnt/20tb/Stash

      # TV_Shows - menno:users 760
      chown menno:users /mnt/20tb/TV_Shows
      chmod 760 /mnt/20tb/TV_Shows
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  environment.etc."local/bin/zfs-backup.sh" = {
    mode = "0755";
    text = ''
      #!/bin/bash
      set -euo pipefail

      DATE=$(date +%Y%m%d-%H%M)
      # Updated DATASETS list to match your actual datasets
      DATASETS="movies tv_shows music astro downloads photos stash isos audiobooks vms old_backups services"
      RETAIN_SNAPSHOTS=24
      BACKUP_POOL="backup"
      SOURCE_POOL="datapool"

      log() {
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
      }

      ensure_backup_pool() {
        if ! zpool list "$BACKUP_POOL" >/dev/null 2>&1; then
          log "ERROR: Backup pool '$BACKUP_POOL' does not exist!"
          return 1
        fi
      }

      check_dataset_exists() {
        local pool=$1
        local dataset=$2
        zfs list "$pool/$dataset" >/dev/null 2>&1
        return $?
      }

      create_backup_dataset() {
        local dataset=$1
        local source_pool="$SOURCE_POOL"
        local backup_pool="$BACKUP_POOL"
        
        # Get properties from source dataset
        local props=$(zfs get -H -o property,value all "$source_pool/$dataset" | \
                     grep -E '^(compression|recordsize|atime|relatime|xattr|acltype)' | \
                     awk '{printf "-o %s=%s ", $1, $2}')
        
        log "Creating backup dataset $backup_pool/$dataset with matching properties"
        # shellcheck disable=SC2086
        zfs create -p ${props} "$backup_pool/$dataset"
        
        # Set some backup-specific properties
        zfs set readonly=on "$backup_pool/$dataset"
        zfs set snapdir=visible "$backup_pool/$dataset"
        log "Successfully created backup dataset $backup_pool/$dataset"
      }

      get_latest_snapshot() {
        local pool=$1
        local dataset=$2
        local snapshot
        snapshot=$(zfs list -t snapshot -H -o name "$pool/$dataset" 2>/dev/null | grep backup- | tail -n1) || true
        echo "$snapshot"
      }

      # Ensure backup pool exists
      ensure_backup_pool

      for ds in $DATASETS; do
          log "Processing dataset $ds"
          
          # Check if source dataset exists
          if ! check_dataset_exists "$SOURCE_POOL" "$ds"; then
              log "Skipping $ds - source dataset $SOURCE_POOL/$ds does not exist"
              continue
          fi
          
          # Create backup dataset if it doesn't exist
          if ! check_dataset_exists "$BACKUP_POOL" "$ds"; then
              log "Backup dataset $BACKUP_POOL/$ds does not exist"
              create_backup_dataset "$ds"
          fi
          
          # Create new snapshot
          local snapshot_name="$SOURCE_POOL/$ds@backup-$DATE"
          log "Creating new snapshot $snapshot_name"
          zfs snapshot "$snapshot_name"
          
          LATEST_BACKUP=$(get_latest_snapshot "$BACKUP_POOL" "$ds")
          
          if [ -z "$LATEST_BACKUP" ]; then
              log "No existing backup found - performing full backup of $ds"
              zfs send "$snapshot_name" | zfs receive -F "$BACKUP_POOL/$ds"
          else
              LATEST_SOURCE=$(get_latest_snapshot "$SOURCE_POOL" "$ds" | grep -v "backup-$DATE" | tail -n1)
              if [ -n "$LATEST_SOURCE" ]; then
                  log "Performing incremental backup of $ds from $LATEST_SOURCE to backup-$DATE"
                  zfs send -i "$LATEST_SOURCE" "$snapshot_name" | zfs receive -F "$BACKUP_POOL/$ds"
              else
                  log "No suitable source snapshot found for incremental backup - performing full backup of $ds"
                  zfs send "$snapshot_name" | zfs receive -F "$BACKUP_POOL/$ds"
              fi
          fi
          
          log "Cleaning up old snapshots for $ds"
          
          # Cleanup source snapshots
          if snapshots=$(zfs list -t snapshot -H -o name "$SOURCE_POOL/$ds" | grep backup-); then
              echo "$snapshots" | head -n -$RETAIN_SNAPSHOTS | while read -r snap; do
                  log "Removing source snapshot: $snap"
                  zfs destroy "$snap"
              done
          fi
          
          # Cleanup backup snapshots
          if snapshots=$(zfs list -t snapshot -H -o name "$BACKUP_POOL/$ds" | grep backup-); then
              echo "$snapshots" | head -n -$RETAIN_SNAPSHOTS | while read -r snap; do
                  log "Removing backup snapshot: $snap"
                  zfs destroy "$snap"
              done
          fi
      done

      log "Backup completed successfully"
    '';
  };

  systemd.services.zfs-backup = {
    description = "ZFS Backup Service";
    requires = [ "zfs.target" ];
    after = [ "zfs.target" ];
    path = [ pkgs.zfs ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/etc/local/bin/zfs-backup.sh";
      User = "root";
    };
  };

  systemd.timers.zfs-backup = {
    description = "Run ZFS backup every 4 hours";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "15min";
      OnUnitActiveSec = "4h";
      RandomizedDelaySec = "5min";
    };
  };
}