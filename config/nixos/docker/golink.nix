{ config, pkgs, ... }:

{
  environment.etc."docker/golink/docker-compose.yml".source = ./golink/docker-compose.yml;
  environment.etc."docker/golink/.env".source = ./golink/.env;

  systemd.services.golink = {
    description = "GoLink Docker Compose Service";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose -f /etc/docker/golink/docker-compose.yml up";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose -f /etc/docker/golink/docker-compose.yml down";
      WorkingDirectory = "/etc/docker/golink";
      Restart = "always";
      RestartSec = 10;
    };
    wantedBy = [ "multi-user.target" ];
  };
}
