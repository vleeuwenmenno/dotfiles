{ pkgs, ... }:
{
  services.traefik = {
    enable = true;
    staticConfigOptions = {
      entryPoints = {
        web.address = ":80";
        websecure.address = ":443";
      };
      certificatesResolvers.letsencrypt.acme = {
        email = "menno@vleeuwen.me";
        storage = "/var/lib/traefik/acme.json";
        httpChallenge.entryPoint = "web";
      };
    };
    dynamicConfigOptions = {
      http = {
        # Plex Media Server
        routers.plex = {
          rule = "Host(`plex.vleeuwen.me`)";
          service = "plex";
          entryPoints = [ "websecure" ];
          tls.certResolver = "letsencrypt";
        };
        services.plex.loadBalancer.servers = [ { url = "http://127.0.0.1:32400"; } ];

        # Tautulli (Plex Stats)
        routers.tautulli = {
          rule = "Host(`tautulli.vleeuwen.me`)";
          service = "tautulli";
          entryPoints = [ "websecure" ];
          tls.certResolver = "letsencrypt";
        };
        services.tautulli.loadBalancer.servers = [ { url = "http://127.0.0.1:8181"; } ];

        # Jellyfin
        routers.jellyfin = {
          rule = "Host(`jellyfin.vleeuwen.me`)";
          service = "jellyfin";
          entryPoints = [ "websecure" ];
          tls.certResolver = "letsencrypt";
        };
        services.jellyfin.loadBalancer.servers = [ { url = "http://127.0.0.1:8096"; } ];

        # Overseerr
        routers.overseerr = {
          rule = "Host(`overseerr.vleeuwen.me`)";
          service = "overseerr";
          entryPoints = [ "websecure" ];
          tls.certResolver = "letsencrypt";
        };
        services.overseerr.loadBalancer.servers = [ { url = "http://127.0.0.1:5555"; } ];

        # Immich (Google Photos alternative)
        routers.immich = {
          rule = "Host(`photos.vleeuwen.me`)";
          service = "immich";
          entryPoints = [ "websecure" ];
          tls.certResolver = "letsencrypt";
        };
        services.immich.loadBalancer.servers = [ { url = "http://127.0.0.1:2283"; } ];

        # Gitea Git Server
        routers.gitea = {
          rule = "Host(`git.mvl.sh`)";
          service = "gitea";
          entryPoints = [ "websecure" ];
          tls.certResolver = "letsencrypt";
        };
        services.gitea.loadBalancer.servers = [ { url = "http://127.0.0.1:3030"; } ];

        # Home Assistant
        routers.homeassistant = {
          rule = "Host(`home.vleeuwen.me`)";
          service = "homeassistant";
          entryPoints = [ "websecure" ];
          tls.certResolver = "letsencrypt";
        };
        services.homeassistant.loadBalancer.servers = [ { url = "http://192.168.86.254:8123"; } ];

        # InfluxDB for Home Assistant
        routers.influxdb = {
          rule = "Host(`influxdb.vleeuwen.me`)";
          service = "influxdb";
          entryPoints = [ "websecure" ];
          tls.certResolver = "letsencrypt";
        };
        services.influxdb.loadBalancer.servers = [ { url = "http://192.168.86.254:8086"; } ];

        # Bluemap for Minecraft
        routers.bluemap = {
          rule = "Host(`map.mvl.sh`)";
          service = "bluemap";
          entryPoints = [ "websecure" ];
          tls.certResolver = "letsencrypt";
        };
        services.bluemap.loadBalancer.servers = [ { url = "http://127.0.0.1:3456"; } ];

        # Factorio Server Manager
        routers.factorio = {
          rule = "Host(`fsm.mvl.sh`)";
          service = "factorio";
          entryPoints = [ "websecure" ];
          tls.certResolver = "letsencrypt";
        };
        services.factorio.loadBalancer.servers = [ { url = "http://127.0.0.1:5080"; } ];

        # Resume/CV Website
        routers.personal-site = {
          rule = "Host(`mennovanleeuwen.nl`)";
          service = "personal-site";
          entryPoints = [ "websecure" ];
          tls.certResolver = "letsencrypt";
        };
        services.personal-site.loadBalancer.servers = [ { url = "http://127.0.0.1:4203"; } ];
      };
    };
  };
}
