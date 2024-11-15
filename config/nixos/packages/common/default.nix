{ pkgs, ... }:
{
  imports = [ ./virtualisation.nix ];

  environment.systemPackages = with pkgs; [
    yubikey-manager
    trash-cli
    sqlite # Used for managing SQLite databases (Brave Settings etc.)
    xcp # Rust implementation of cp/mv command
    pandoc # Document converter (Markdown, HTML, PDF etc.) (Mostly used for static site generators)
  ];
}
