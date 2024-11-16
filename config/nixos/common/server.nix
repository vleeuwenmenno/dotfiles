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
      80 # HTTP
      443 # HTTPS
      22 # Git over SSH
      400 # SSH
      25565 # Minecraft
      3456 # Minecraft (Bluemap)
      32400 # Plex
      8096 # Jellyfin

      81 # Nginx Proxy Manager
      5334 # Duplicati Notifications
      7788 # Sabnzbd
      #8085 # Qbittorrent
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
    allowedUDPPorts = [
      51820 # WireGuard
    ];

    # Extra rules for allowing internal communication
    # extraCommands = ''
    #   # Allow established connections
    #   iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

    #   # Allow all traffic on internal networks
    #   iptables -A INPUT -i docker0 -j ACCEPT
    #   iptables -A INPUT -i tailscale0 -j ACCEPT

    #   # Allow traffic between Docker containers
    #   iptables -A DOCKER-USER -i docker0 -o docker0 -j ACCEPT
    # '';
  };
}
