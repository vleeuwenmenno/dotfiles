{ config, pkgs, ... }:

{
  environment.etc."docker/stash/docker-compose.yml".source = ./stash/docker-compose.yml;

  systemd.services.stash = {
    description = "stash Docker Compose Service";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose -f /etc/docker/stash/docker-compose.yml up";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose -f /etc/docker/stash/docker-compose.yml down";
      WorkingDirectory = "/etc/docker/stash";
      Restart = "always";
      RestartSec = 10;
    };
    wantedBy = [ "multi-user.target" ];
  };
}
