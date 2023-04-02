{
  description = "NixOS systems and tools by mitchellh";

  inputs = {
    # Pin our primary nixpkgs repository. This is the main nixpkgs repository
    # we'll use for our configurations. Be very careful changing this because
    # it'll impact your entire system.
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";

    # We use the unstable nixpkgs repo for some packages.
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";

      # We want home-manager to use the same set of nixpkgs as our system.
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: let
  in {
    nixosConfigurations = {

      nixos = inputs.nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
        ./system.nix
	    ./user.nix


	    home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.co5mo = import ./home-manager.nix;

            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          }
        ];
        specialArgs = { inherit inputs; };
      };
    };
  };
}
