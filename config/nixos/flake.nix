{
  description = "menno's dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.05";
  };

  outputs =
    { self, nixpkgs }:
    {
      nixosConfigurations = {
        "mennos-laptop" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./configuration.nix
            ./nvidia.nix
            { networking.hostName = "mennos-laptop"; }
          ];
        };
        "mennos-gamingpc" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./configuration.nix
            { networking.hostName = "mennos-desktop"; }
          ];
        };
      };
    };
}