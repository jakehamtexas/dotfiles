{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages.${system}.default = home-manager.defaultPackage.${system};

        homeConfigurations = {
          me = home-manager.lib.homeManagerConfiguration {
            system = system;
            homeDirectory = "/home/jakeh";
            username = "jakeh";
            configuration.imports = [./common.nix] [/homes/me.nix];
          };

          them = home-manager.lib.homeManagerConfiguration {
            system = system;
            homeDirectory = "/home/jake";
            username = "jake";
            configuration.imports = [./common.nix] [/homes/them.nix];
          };
        };
      }
    );
}
