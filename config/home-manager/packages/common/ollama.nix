{
  config,
  pkgs,
  pkgs-unstable,
  ...
}:
{
  # Ollama will be installed in the hosts/ configuration depending on what the host is of this system
  # If none is registered, the fallback will be used which installs ollama without GPU acceleration support.
  systemd.user.services.ollama = {
    Unit = {
      Description = "Ollama Service";
      After = [ "network.target" ];
    };

    Service = {
      # This resolves to for example: /home/menno/.nix-profile/bin/ollama
      ExecStart = "${config.home.profileDirectory}/bin/ollama serve";
      Restart = "always";
      RestartSec = "10";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
