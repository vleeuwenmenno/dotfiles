{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [ /etc/nixos/hardware-configuration.nix ];
  networking.hostName = "mennos-gamingpc";

  # Enable Vulkan support for AMD graphics cards
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ amdvlk ];

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;

    # Enable the latest AMDGPU drivers
    extraPackages = with pkgs; [
      amdvlk
      rocm-opencl-icd
      rocm-opencl-runtime
    ];
  };

  # Add ROCm packages
  environment.systemPackages = with pkgs; [
    rocmPackages.rocm-smi
    rocmPackages.clr
    rocmPackages.rocm-core
    rocmPackages.hipcc
    rocmPackages.rocm-device-libs
  ];
}
