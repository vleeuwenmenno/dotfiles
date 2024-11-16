{ config, pkgs, ... }:
{
  services.openssh = {
    enable = true;
    ports = [ 400 ];
    settings = {
      PasswordAuthentication = false;
      AllowUsers = [ "menno" ];
      X11Forwarding = false;
      PermitRootLogin = "prohibit-password";
      AllowTCPForwarding = true;
      AllowAgentForwarding = true;
      PermitEmptyPasswords = false;
      PubkeyAuthentication = true;
    };
  };

  networking = {
    nat.enable = true;
    nat.enableIPv6 = true;

    firewall = {
      enable = true;

      # Only truly external ports
      allowedTCPPorts = [
        80 # HTTP
        443 # HTTPS
        22 # Git over SSH
        400 # SSH
        25565 # Minecraft
        3456 # Minecraft (Bluemap)
        32400 # Plex
        8096 # Jellyfin
      ];

      allowedUDPPorts = [
        51820 # WireGuard
      ];

      # Internal ports
      interfaces =
        let
          internalPorts = [
            81 # Nginx Proxy Manager
            5334 # Duplicati Notifications
            7788 # Sabnzbd
            8085 # Qbittorrent
            3030 # Gitea
            5080 # Factorio Server Manager
            5555 # Overseerr
            9696 # Prowlarr
            7878 # Radarr
            8686 # Lidarr
            8989 # Sonarr
            8386 # Whisparr
            8191 # Flaresolerr
            9999 # Stash
          ];
        in
        {
          "docker0".allowedTCPPorts = internalPorts;
          "tailscale0".allowedTCPPorts = internalPorts;
          "enp39s0".allowedTCPPorts = internalPorts;
        };

      # Required for Tailscale
      checkReversePath = "loose";
    };
  };
}
