{ config, pkgs, ... }: {
  boot.kernelModules = [ "kvm-amd" ];
  
  virtualisation = {
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
