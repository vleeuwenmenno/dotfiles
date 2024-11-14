{ config, pkgs, ... }:

{
  environment.etc."docker/torrent/docker-compose.yml".source = ./torrent/docker-compose.yml;

  systemd.services.torrent = {
    description = "Torrent Docker Compose Service";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose -f /etc/docker/torrent/docker-compose.yml up";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose -f /etc/docker/torrent/docker-compose.yml down";
      WorkingDirectory = "/etc/docker/torrent";
      Restart = "always";
      RestartSec = 10;
    };
    wantedBy = [ "multi-user.target" ];
  };
}
