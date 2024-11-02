{ config, pkgs, ... }:
{
  services.udev.packages = [ pkgs.yubikey-personalization ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Install pam_u2f command
  environment.systemPackages = with pkgs; [
    pam_u2f
    libnotify
  ];

  security.pam.services = {
    sudo.u2fAuth = true;
    lock.u2fAuth = true;
    gnome-screensaver.u2fAuth = true;
    "polkit-1".u2fAuth = true;
  };

  # Enable polkit
  security.polkit.enable = true;

  # Add custom polkit rules for 1Password
  environment.etc."polkit-1/rules.d/90-1password-yubikey.rules".text = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "com.1password.1Password.unlock") {
        var authtype = subject.local ? "auth_admin_keep" : "auth_admin";
        return polkit.Result.AUTH_ADMIN;
      }
    });
  '';

  # Make sure polkit is using the right authentication agent
  services.xserver.displayManager.gdm = {
    enable = true;
    autoSuspend = false;
  };

  # GNOME keyring configuration
  security.pam.services."gnome-keyring" = {
    text = ''
      auth optional pam_u2f.so
      auth optional pam_unix.so nullok try_first_pass
      session optional pam_keyinit.so force revoke
      session optional pam_gnome_keyring.so auto_start
    '';
  };
}
