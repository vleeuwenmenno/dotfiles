{ config, pkgs, ... }:

{
  environment.etc."docker/factorio/docker-compose.yml".source = ./factorio/docker-compose.yml;

  systemd.services.factorio = {
    description = "Factorio Server Manager Docker Compose Service";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose -f /etc/docker/factorio/docker-compose.yml up";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose -f /etc/docker/factorio/docker-compose.yml down";
      WorkingDirectory = "/etc/docker/factorio";
      Restart = "always";
      RestartSec = 10;
    };
    wantedBy = [ "multi-user.target" ];
  };
}
