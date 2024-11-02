{ config, pkgs, ... }:
let
  # List of authorized YubiKey serial numbers
  authorizedKeys = [
    "10627969"
    "30079068"
  ];

  sudo-wrapper = pkgs.writeScriptBin "sudo" ''
    #!${pkgs.bash}/bin/bash

    # Function to show both terminal and desktop notification
    notify() {
      echo "$1" >&2
      ${pkgs.libnotify}/bin/notify-send -u critical "Sudo Authentication" "$1"
    }

    # Function to check if any of our authorized YubiKeys are present
    check_yubikey() {
      # Get list of connected YubiKeys
      local keys=$(${pkgs.yubikey-manager}/bin/ykman list 2>/dev/null)
      
      # Check if any of our authorized keys are in the list
      for serial in ${toString authorizedKeys}; do
        if echo "$keys" | grep -q "$serial"; then
          return 0  # Found an authorized key
        fi
      done
      return 1  # No authorized keys found
    }

    # Check if we already have sudo permissions
    if [ "$EUID" -eq 0 ]; then
      exec /run/wrappers/bin/sudo "$@"
    fi

    # Check for YubiKey presence
    if check_yubikey; then
      # YubiKey is present, show touch prompt
      if [ -t 1 ]; then  # Only show terminal message if interactive
        echo -e "\033[1;34mPlease touch your YubiKey to authenticate...\033[0m" >&2
      fi
      ${pkgs.libnotify}/bin/notify-send -u normal \
        -i security-high \
        "YubiKey Authentication" \
        "Please touch your YubiKey to authenticate..."
    fi

    # Execute sudo with all original arguments
    # This will fall back to password auth if no YubiKey is present
    exec /run/wrappers/bin/sudo "$@"
  '';
in
{
  services.udev.packages = [ pkgs.yubikey-personalization ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  environment.systemPackages = with pkgs; [
    pam_u2f
    libnotify
    sudo-wrapper
  ];

  # Use normal U2F config without trying to modify PAM
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

  # Make sure the wrapper sudo is used instead of the system one
  environment.shellAliases = {
    sudo = "${sudo-wrapper}/bin/sudo";
  };
}
