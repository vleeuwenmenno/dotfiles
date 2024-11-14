{ config, pkgs, ... }:

{
  environment.etc."docker/arr-stack/docker-compose.yml".source = ./arr-stack/docker-compose.yml;

  systemd.services.arr-stack = {
    description = "arr-stack Docker Compose Service";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose -f /etc/docker/arr-stack/docker-compose.yml up";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose -f /etc/docker/arr-stack/docker-compose.yml down";
      WorkingDirectory = "/etc/docker/arr-stack";
      Restart = "always";
      RestartSec = 10;
    };
    wantedBy = [ "multi-user.target" ];
  };
}
