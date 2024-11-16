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

      # External ports
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

      # Required for Tailscale
      checkReversePath = "loose";
    };
  };
}
