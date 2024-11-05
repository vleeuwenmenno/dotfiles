{ config, pkgs, ... }:

{
  environment.etc."docker/duplicati/docker-compose.yml".source = ./duplicati/docker-compose.yml;

  systemd.services.duplicati = {
    description = "Duplicati Backup Server Docker Compose Service";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose -f /etc/docker/duplicati/docker-compose.yml up";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose -f /etc/docker/duplicati/docker-compose.yml down";
      WorkingDirectory = "/etc/docker/duplicati";
      Restart = "always";
      RestartSec = 10;
    };
    wantedBy = [ "multi-user.target" ];
  };
}
