{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {home-manager, ...}: let
    system = builtins.currentSystem;
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
        username = "Jake Hamilton";
        configuration.imports = [./common.nix] [/homes/them.nix];
      };
    };
  };
}
