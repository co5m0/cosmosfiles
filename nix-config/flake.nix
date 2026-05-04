{
  description = "A Nix Flake setup to configure system and services";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; # Choose a proper channel
    home-manager = {
      url = "github:nix-community/home-manager/master"; # Add home-manager input
      inputs.nixpkgs.follows = "nixpkgs";
    };
    serena = {
      url = "github:oraios/serena";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    jail-nix.url = "sourcehut:~alexdavid/jail.nix";
    # test.url = "git+https://gist.github.com/75397159e13a522839561201d35dd306.git";
    dagger = {
      url = "github:dagger/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      serena,
      jail-nix,
      dagger,
      ...
    }:
    let

      system = "x86_64-linux"; # Specify system architecture

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      jail = jail-nix.lib.init pkgs;
    in
    {
      formatter.${pkgs.system} = nixpkgs.legacyPackages.${pkgs.system}.nixfmt;
      homeConfigurations.co5mo = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit serena jail dagger; };
        modules = [
          ./home-manager.nix
        ];
      };
    };
}
