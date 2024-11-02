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
      # SSH
      400
    ];
    allowedUDPPorts = [ ];
  };
}
