{ config, pkgs, ... }:

{
  environment.etc."docker/immich/docker-compose.yml".source = ./immich/docker-compose.yml;
  environment.etc."docker/immich/.env".source = ./immich/.env;
  environment.etc."docker/immich/hwaccel.ml.yml".source = ./immich/hwaccel.ml.yml;
  environment.etc."docker/immich/hwaccel.transcoding.yml".source = ./immich/hwaccel.transcoding.yml;

  systemd.services.immich = {
    description = "Immich Docker Compose Service";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose -f /etc/docker/immich/docker-compose.yml up";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose -f /etc/docker/immich/docker-compose.yml down";
      WorkingDirectory = "/etc/docker/immich";
      Restart = "always";
      RestartSec = 10;
    };
    wantedBy = [ "multi-user.target" ];
  };
}
