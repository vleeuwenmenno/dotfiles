{ config, pkgs, ... }:

{
  environment.etc."docker/plex/docker-compose.yml".source = ./plex/docker-compose.yml;

  systemd.services.plex = {
    description = "plex Docker Compose Service";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose -f /etc/docker/plex/docker-compose.yml up";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose -f /etc/docker/plex/docker-compose.yml down";
      WorkingDirectory = "/etc/docker/plex";
      Restart = "always";
      RestartSec = 10;
    };
    wantedBy = [ "multi-user.target" ];
  };
}
