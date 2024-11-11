{ config, pkgs, ... }:

{
  environment.etc."docker/gitea/docker-compose.yml".source = ./gitea/docker-compose.yml;
  environment.etc."docker/gitea/act-runner-config.yaml".source = ./gitea/act-runner-config.yaml;

  systemd.services.gitea = {
    description = "Gitea Docker Compose Service";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose -f /etc/docker/gitea/docker-compose.yml up";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose -f /etc/docker/gitea/docker-compose.yml down";
      WorkingDirectory = "/etc/docker/gitea";
      Restart = "always";
      RestartSec = 10;
    };
    wantedBy = [ "multi-user.target" ];
  };
}
