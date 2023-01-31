{
  description = "ghc.nix flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master"; #"github:nixos/nixpkgs/nixos-22.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, ... }: with nixpkgs.lib; let
    supportedSystems = nixpkgs.lib.systems.flakeExposed;
    perSystem = genAttrs supportedSystems;

    pkgsFor = system: import nixpkgs { inherit system; };
    unstablePkgsFor = system: import nixpkgs-unstable { inherit system; };

    all-cabal = {
      owner = "commercialhaskell";
      repo = "all-cabal-hashes";
      rev = "f4b3c68d6b5b128503bc1139cfc66e0537bccedd";
      sha256 = "0h8si8z462a21liw847g576yhpp0zn1m1an8gwscxb9sg4b0wqg4";
    };
  in
  {
    devShells = perSystem (system: {
      default = import ./ghc.nix {
        inherit system;
        all-cabal-hashes = with all-cabal; builtins.fetchurl {
          inherit sha256;
          url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
          name = "${repo}-${rev}.tar.gz";
        };
        withHadrianDeps = true;
        withIde = true;
        nixpkgs = pkgsFor system;
        nixpkgs-unstable = unstablePkgsFor system;
      };
    });
    formatter = perSystem (system: (pkgsFor system).nixpkgs-fmt);
  };
}
