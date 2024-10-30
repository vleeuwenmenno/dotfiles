{ config, pkgs, ... }: {
  users.users.menno = {
    isNormalUser = true;
    description = "Menno van Leeuwen";
    extraGroups = [ 
      "networkmanager" 
      "wheel" 
      "kvm" 
      "libvirtd"
      "qemu-libvirtd"
    ];
    packages = with pkgs; [ ];
  };
}
