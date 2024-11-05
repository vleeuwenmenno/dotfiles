{
  description = "menno's dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
    }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations = {
        "mennos-laptop" = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hardware/mennos-laptop.nix
            ./common/workstation.nix
            ./configuration.nix
          ];
          specialArgs = {
            inherit pkgs-unstable;
            isWorkstation = true;
            isServer = false;
          };
        };

        "mennos-gamingpc" = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hardware/mennos-gamingpc.nix
            ./common/workstation.nix
            ./configuration.nix
          ];
          specialArgs = {
            inherit pkgs-unstable;
            isWorkstation = true;
            isServer = false;
          };
        };

        "mennos-server" = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hardware/mennos-server.nix
            ./common/server.nix
            ./configuration.nix
          ];
          specialArgs = {
            inherit pkgs-unstable;
            isWorkstation = false;
            isServer = true;
          };
        };
      };
    };
}
