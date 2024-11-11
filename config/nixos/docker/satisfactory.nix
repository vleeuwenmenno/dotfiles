{ config, pkgs, ... }:

{
  environment.etc."docker/satisfactory/docker-compose.yml".source = ./satisfactory/docker-compose.yml;

  systemd.services.satisfactory = {
    description = "Satisfactory Game Server Docker Compose Service";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose -f /etc/docker/satisfactory/docker-compose.yml up";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose -f /etc/docker/satisfactory/docker-compose.yml down";
      WorkingDirectory = "/etc/docker/satisfactory";
      Restart = "always";
      RestartSec = 10;
    };
    wantedBy = [ "multi-user.target" ];
  };
}
