{ config, pkgs, ... }:
{
  # OpenSSH server
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

  # Open ports in the firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      400 # SSH
      80 # HTTP
      443 # HTTPS

      22 # Git over SSH
      32400 # Plex

      # Interal services
      81 # Nginx Proxy Manager
      7788 # Sabnzbd
      8085 # Qbittorrent
      3030 # Gitea

      # Arr services
      5555 # Overseerr
      9696 # Prowlarr
      7878 # Radarr
      8686 # Lidarr
      8989 # Sonarr
      8386 # Whisparr
      8191 # Flaresolerr
    ];
    allowedUDPPorts = [
      51820 # WireGuard
    ];
  };
}
