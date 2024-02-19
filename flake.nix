{
    description = "My Dotfiles Flake";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
        home-manager.url = "github:nix-community/home-manager";

        darwin = {
            url = "github:/lnl7/nix-darwin/master";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        home-manager = {
            url = "github:nix-community/home-manager/master";
            inputs.nixpkgs.follows = "nixpkgs"; 
        };
    };

    outputs = { self, nixpkgs, home-manager, ... }:
        let
            lib = nixpkgs.lib;
            pkgs = nixpacks.legacyPackages.${nixpkgs.system};
        in {
            homeConfigurations = {
                menno = gome-manager.lib.homeManagerConfiguration {
                    inherit pkgs;
                    modules = [
                        ./home.nix
                    ];
                };
            };
        }
}