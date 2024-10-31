{ config, pkgs, ... }: {
  boot.kernelModules = [ "kvm-amd" ];

  virtualisation = {
    docker = {
      enable = true;
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
