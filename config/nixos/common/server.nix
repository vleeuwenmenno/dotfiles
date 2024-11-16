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
        53 # DNS
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

      extraCommands = ''
        # Allow established connections
        iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

        # Allow internal network traffic
        iptables -A INPUT -i docker0 -j ACCEPT
        iptables -A INPUT -i tailscale0 -j ACCEPT
        iptables -A INPUT -s 192.168.86.0/24 -j ACCEPT

        # Allow Docker inter-network communication
        iptables -A FORWARD -i br-* -o br-* -j ACCEPT
        iptables -A FORWARD -i docker0 -o br-* -j ACCEPT
        iptables -A FORWARD -i br-* -o docker0 -j ACCEPT

        # Allow Docker subnet traffic but only internally
        iptables -A INPUT -s 172.16.0.0/12 -i docker0 -j ACCEPT
        iptables -A INPUT -s 172.16.0.0/12 -i br-+ -j ACCEPT

        # Allow Docker container communication
        iptables -A DOCKER-USER -i docker0 -o docker0 -j ACCEPT
      '';

      # Required for Tailscale
      checkReversePath = "loose";
    };
  };
}
