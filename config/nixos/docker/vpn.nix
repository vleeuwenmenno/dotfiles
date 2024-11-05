{ config, pkgs, ... }:

{
  environment.etc."docker/vpn/docker-compose.yml".source = ./vpn.yml;

  systemd.services.wireguard = {
    description = "Wireguard Docker Compose Service";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose -f /etc/docker/vpn/docker-compose.yml up";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose -f /etc/docker/vpn/docker-compose.yml down";
      WorkingDirectory = "/etc/docker/vpn";
      Restart = "always";
      RestartSec = 10;
    };
    wantedBy = [ "multi-user.target" ];
  };
}
