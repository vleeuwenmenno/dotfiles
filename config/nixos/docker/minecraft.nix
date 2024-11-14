{ config, pkgs, ... }:

{
  environment.etc."docker/minecraft/docker-compose.yml".source = ./minecraft/docker-compose.yml;
  environment.etc."docker/minecraft/shell.sh".source = ./minecraft/shell.sh;

  systemd.services.minecraft = {
    description = "minecraft Docker Compose Service";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose -f /etc/docker/minecraft/docker-compose.yml up";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose -f /etc/docker/minecraft/docker-compose.yml down";
      WorkingDirectory = "/etc/docker/minecraft";
      Restart = "always";
      RestartSec = 10;
    };
    wantedBy = [ "multi-user.target" ];
  };
}
