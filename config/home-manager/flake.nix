{
  description = "menno's dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

    # Pinned versions for specific packages (https://nixhub.io)
    nixpkgs-go.url = "github:nixos/nixpkgs/d4f247e89f6e10120f911e2e2d2254a050d0f732";
    nixpkgs-vscode.url = "github:nixos/nixpkgs/d4f247e89f6e10120f911e2e2d2254a050d0f732";
    nixpkgs-zed.url = "github:nixos/nixpkgs/41dea55321e5a999b17033296ac05fe8a8b5a257";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-go,
      nixpkgs-vscode,
      nixpkgs-zed,
      home-manager,
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      pkgs-go = import nixpkgs-go {
        inherit system;
        config.allowUnfree = true;
      };
      pkgs-vscode = import nixpkgs-vscode {
        inherit system;
        config.allowUnfree = true;
      };
      pkgs-zed = import nixpkgs-zed {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      homeConfigurations = {
        "mennos-gamingpc" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home.nix ];
          extraSpecialArgs = {
            inherit
              pkgs
              pkgs-go
              pkgs-vscode
              pkgs-zed
              ;
            isServer = false;
          };
        };

        "mennos-server" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home.nix ];
          extraSpecialArgs = {
            inherit pkgs pkgs-go;
            isServer = true;
          };
        };

        "mennos-laptop" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home.nix ];
          extraSpecialArgs = {
            inherit
              pkgs
              pkgs-go
              pkgs-vscode
              pkgs-zed
              ;
            isServer = false;
          };
        };

        "homeserver-pc" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home.nix ];
          extraSpecialArgs = {
            inherit pkgs pkgs-go;
            isServer = true;
          };
        };
      };
    };
}
