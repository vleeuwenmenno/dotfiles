{ config, pkgs, ... }:
{
  systemd.user.services = {
    onepassword-autostart = {
      Unit = {
        Description = "Start 1Password on login";
        # Change 'After' to use 'graphical-session.target' directly
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs._1password-gui}/bin/1password";
        Restart = "no";
      };
      Install = {
        WantedBy = [ "default.target" ];  # Target used for generic user services
      };
    };

    trayscale-autostart = {
      Unit = {
        Description = "Start Trayscale on login";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.trayscale}/bin/trayscale";
        Restart = "no";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    vesktop-autostart = {
      Unit = {
        Description = "Start Vesktop on login";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.vesktop}/bin/vesktop";
        Restart = "no";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    telegram-autostart = {
      Unit = {
        Description = "Start Telegram Desktop on login";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.telegram-desktop}/bin/telegram-desktop";
        Restart = "no";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    whatsapp-for-linux-autostart = {
      Unit = {
        Description = "Start WhatsApp for Linux on login";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.whatsapp-for-linux}/bin/whatsapp-for-linux";
        Restart = "no";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    spotify-autostart = {
      Unit = {
        Description = "Start Spotify on login";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.spotify}/bin/spotify";
        Restart = "no";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}