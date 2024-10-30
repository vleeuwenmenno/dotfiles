{ config, pkgs, ... }:
{
  systemd.user.services = {
    onepassword-autostart = {
      Unit = {
        Description = "Start 1Password on login";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs._1password-gui}/bin/1password";
        Restart = "no";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    trayscale-autostart = {
      Unit = {
        Description = "Start Trayscale on login";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.trayscale}/bin/trayscale";
        Restart = "no";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    vesktop-autostart = {
      Unit = {
        Description = "Start Vesktop on login";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.vesktop}/bin/vesktop";
        Restart = "no";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    telegram-autostart = {
      Unit = {
        Description = "Start Telegram Desktop on login";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.telegram-desktop}/bin/telegram-desktop";
        Restart = "no";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    spotify-autostart = {
      Unit = {
        Description = "Start Spotify on login";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.spotify}/bin/spotify";
        Restart = "no";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
