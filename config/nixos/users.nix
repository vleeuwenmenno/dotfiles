{ config, pkgs, ... }:
{
  users.users.menno = {
    shell = pkgs.bash;
    isNormalUser = true;
    description = "Menno van Leeuwen";
    extraGroups = [
      "networkmanager"
      "wheel"
      "kvm"
      "libvirtd"
      "qemu-libvirtd"
      "docker"
      "video"
      "render"
    ];
  };
}
