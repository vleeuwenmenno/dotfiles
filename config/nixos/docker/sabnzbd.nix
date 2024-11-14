{ config, pkgs, ... }:

{
  environment.etc."docker/sabnzbd/docker-compose.yml".source = ./sabnzbd/docker-compose.yml;

  systemd.services.sabnzbd = {
    description = "sabnzbd Docker Compose Service";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose -f /etc/docker/sabnzbd/docker-compose.yml up";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose -f /etc/docker/sabnzbd/docker-compose.yml down";
      WorkingDirectory = "/etc/docker/sabnzbd";
      Restart = "always";
      RestartSec = 10;
    };
    wantedBy = [ "multi-user.target" ];
  };
}
