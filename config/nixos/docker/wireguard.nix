{ config, pkgs, ... }:

{
  environment.etc."docker/wireguard/docker-compose.yml".source = ./wireguard/docker-compose.yml;

  systemd.services.wireguard = {
    description = "Wireguard Docker Compose Service";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose -f /etc/docker/wireguard/docker-compose.yml up";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose -f /etc/docker/wireguard/docker-compose.yml down";
      WorkingDirectory = "/etc/docker/wireguard";
      Restart = "always";
      RestartSec = 10;
    };
    wantedBy = [ "multi-user.target" ];
  };
}
