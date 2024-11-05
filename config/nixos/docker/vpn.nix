{ config, pkgs, ... }:
{
  services.docker-compose = {
    enable = true;
    containers = {
      wireguard = {
        image = "lscr.io/linuxserver/wireguard:latest";
        containerName = "wireguard";
        capAdd = [ "NET_ADMIN" ];
        environment = {
          PEERS = "fold6,pc,laptop";
        };
        volumes = [ "./wireguard:/config" ];
        ports = [ "51820:51820/udp" ];
        sysctls = {
          "net.ipv4.conf.all.src_valid_mark" = 1;
        };
        restartPolicy = "unless-stopped";
      };
    };
  };
}
