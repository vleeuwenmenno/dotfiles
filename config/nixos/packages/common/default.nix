{ pkgs, ... }:
{
  imports = [ ./virtualization.nix ];

  environment.systemPackages = with pkgs; [ yubikey-manager ];
}
