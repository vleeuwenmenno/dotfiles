{ config, pkgs, ... }:
{
  environment.etc."docker/nginx-proxy-manager/docker-compose.yml".source = ./nginx-proxy-manager/docker-compose.yml;
  environment.etc."docker/nginx-proxy-manager/.env".source = ./nginx-proxy-manager/.env;

  systemd.services.nginx-proxy-manager = {
    description = "nginx-proxy-manager Docker Compose Service";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose -f /etc/docker/nginx-proxy-manager/docker-compose.yml up";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose -f /etc/docker/nginx-proxy-manager/docker-compose.yml down";
      WorkingDirectory = "/etc/docker/nginx-proxy-manager";
      Restart = "always";
      RestartSec = 10;
    };
    wantedBy = [ "multi-user.target" ];
  };
}
