{
    description = "My Dotfiles Flake";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";

        home-manager = {
            url = "github:nix-community/home-manager/release-23.11";
            inputs.nixpkgs.follows = "nixpkgs"; 
        };
    };

    outputs = { self, nixpkgs, home-manager, ... }:
        let
            lib = nixpkgs.lib;
            system = "x86_64-linux";
            pkgs = nixpkgs.legacyPackages.${system};
        in {
            homeConfigurations = {
                menno = home-manager.lib.homeManagerConfiguration {
                    inherit pkgs;
                    modules = [
                        ./home.nix
                    ];
                };
            };
            nixos = nixpkgs.lib.nixosSystem {
                modules = [
                    ./configuration.nix
                    home-manager.nixosModules.home-manager
                    {
                        home-manager.useGlobalPkgs = true;
                        home-manager.useUserPackages = true;
                        home-manager.users.livenux = import ./home.nix;
                    }
                ];
            };
        };
}