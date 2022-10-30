{
  description = "ghc.nix flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.05";
    # NOTE: matches nixpkgs-unstable from sources.nix
    nixpkgs-unstable.url = "github:nixos/nixpkgs/e14f9fb57315f0d4abde222364f19f88c77d2b79";
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
      sha256 = "1x341yzi40xr6dxx2dvah4g943daih1y6dm4jh1d5w9fjff9v5s7";
    };
  in
  {
    devShells = perSystem (system: {
      default = import ./ghc.nix {
        inherit system;
        all-cabal-hashes = with all-cabal; builtins.fetchurl {
          inherit sha256;
          url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
          name = "all-cabal-hashes-${rev}.tar.gz";
        };
        withHadrianDeps = true;
        withIde = true;
        nixpkgs = pkgsFor system;
        nixpkgs-unstable = unstablePkgsFor system;
      };
    });
    formatter = perSystem (system:
      let
        pkgs = pkgsFor system;
      in
      pkgs.nixpkgs-fmt);
  };
}
