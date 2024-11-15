{
  config,
  pkgs,
  pkgs-unstable,
  ...
}:
{
  boot.kernelModules = [ "kvm-amd" ];

  environment.systemPackages = with pkgs; [
    qemu
    OVMF
  ];

  virtualisation = {
    docker = {
      enable = true;
      package = pkgs-unstable.docker;
      autoPrune.enable = true;
      daemon.settings = {
        "live-restore" = false;
      };
    };

    libvirtd = {
      enable = true;

      qemu = {
        package = pkgs.qemu;
        runAsRoot = true;
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = [ pkgs.OVMF.fd ];
        };
      };
    };
  };
}
