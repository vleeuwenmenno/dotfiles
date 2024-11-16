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
    ];
    allowedUDPPorts = [
      51820 # WireGuard
    ];
  };

  # Allow local network access only
  interfaces = {
    "docker0" = {
      allowedTCPPorts = [
        7788 # Sabnzbd
        8085 # Qbittorrent
        81 # Nginx Proxy Manager
        3030 # Gitea
      ];
    };
  };
}
