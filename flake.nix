{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    let
      # TODO: figure out which platforms prismterminal supports
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
      prism = pkgs.callPackage ./package.nix {};
    in
    {
      packages.${system}.default = prism;

      nixosModules = rec {
        prismterminal = import ./nixos prism;
        default = prismterminal;
      };
    };
}
