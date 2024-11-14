{ pkgs, ... }:
{
  imports = [ ./virtualization.nix ];

  environment.systemPackages = with pkgs; [
    yubikey-manager
    trash-cli
    sqlite # Used for managing SQLite databases (Brave Settings etc.)
  ];
}
