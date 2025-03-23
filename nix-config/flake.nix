{
  description = "A Nix Flake setup to configure system and services";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; # Choose a proper channel
    home-manager = {
      url =
        "github:nix-community/home-manager/master"; # Add home-manager input
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
    let

      system = "aarch64-linux"; # Specify system architecture
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in {

      formatter.aarch64-linux = nixpkgs.legacyPackages.aarch64-linux.nixfmt;
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          inherit system;

          modules = [
            ./configuration.nix # Include the main NixOS configuration
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit pkgs; };
              home-manager.users.marioconsalvo = import ./home-manager.nix;

              # Optionally, use home-manager.extraSpecialArgs to pass
              # arguments to home.nix
            }
          ];
        };
      };
    };
}

