{ config, pkgs, ... }:

{
  environment.etc."docker/upnp/docker-compose.yml".source = ./upnp/docker-compose.yml;

  systemd.services.upnp = {
    description = "UPnP Docker Compose Service";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose -f /etc/docker/upnp/docker-compose.yml up";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose -f /etc/docker/upnp/docker-compose.yml down";
      WorkingDirectory = "/etc/docker/upnp";
      Restart = "always";
      RestartSec = 10;
    };
    wantedBy = [ "multi-user.target" ];
  };
}
