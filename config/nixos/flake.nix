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
            ./hardware/mennos-laptop.nix
            ./common/workstation.nix
            ./configuration.nix
          ];
          specialArgs = {
            isWorkstation = true;
            isServer = false;
          };
        };
        "mennos-gamingpc" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hardware/mennos-gamingpc.nix
            ./common/workstation.nix
            ./configuration.nix
          ];
          specialArgs = {
            isWorkstation = true;
            isServer = false;
          };
        };
        "mennos-server" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hardware/mennos-server.nix
            ./common/server.nix
            ./configuration.nix
          ];
          specialArgs = {
            isWorkstation = false;
            isServer = true;
          };
        };
      };
    };
}
