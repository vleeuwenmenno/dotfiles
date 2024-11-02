{ config, pkgs, ... }:
{
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  environment.systemPackages = with pkgs; [ gnome3.gnome-session ];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "euro";
  };

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Open ports in the firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      # RDP (Gnome Remote Desktop)
      3389
      3390
      3391

      # SSH
      400
    ];
    allowedUDPPorts = [
      # RDP (Gnome Remote Desktop)
      3389
      3390
      3391
    ];
  };

  # OpenSSH server
  services.openssh = {
    enable = true;
    ports = [ 400 ];
    settings = {
      PasswordAuthentication = false;
      AllowUsers = [ "menno" ];
      X11Forwarding = true;
      PermitRootLogin = "prohibit-password";
      AllowTCPForwarding = true;
      AllowAgentForwarding = true;
      PermitEmptyPasswords = false;
      PubkeyAuthentication = true;
    };
  };
}
