{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = {
    flake-utils,
    nixpkgs,
    ...
  }: {
    packages.x86_64-linux.default = let
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
    in
      pkgs.buildEnv {
        name = "my-packages";
        paths = [
          pkgs.rustup
          pkgs.alejandra
        ];
      };
    foo = flake-utils.lib.eachDefaultSystem (
      system: let
        trace = builtins.trace;
      in {
        k = trace system "hi";
      }
    );
  };
}
