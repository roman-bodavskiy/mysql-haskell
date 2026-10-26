{
  inputs = {
    common.url = "github:nammayatri/common?ref=ghc-98-upgrade";
    nixpkgs.follows = "common/nixpkgs";
    flake-parts.follows = "common/flake-parts";
    haskell-flake.follows = "common/haskell-flake";

    word24.url = "github:winterland1989/word24";
    word24.flake = false;

    tcp-streams.url = "github:roman-bodavskiy/tcp-streams?ref=ghc-98-upgrade";
    tcp-streams.flake = false;
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } ({ withSystem, ... }: {
      systems = nixpkgs.lib.systems.flakeExposed;
      imports = [
        inputs.common.flakeModules.ghc98
        inputs.haskell-flake.flakeModule
      ];
      perSystem = { self', pkgs, lib, config, ... }: {
        haskellProjects.default = {

          projectFlakeName = "mysql-haskell";
          # basePackages = pkgs.haskell.packages.ghc927;
          basePackages = config.haskellProjects.ghc98.outputs.finalPackages;

          packages = {
            word24.source = inputs.word24;
            tcp-streams.source = inputs.tcp-streams;
          };

          settings = {
            word24 = {
              check = false;
              broken = false;
              jailbreak = true;
            };
            binary-parsers = {
              broken = false;
              jailbreak = true;
            };
            wire-streams = {
              jailbreak = true;
            };
            tcp-streams = {
              check = false;
              broken = false;
              jailbreak = true;
            };
          };

          autoWire = [ "packages" "checks" "devShells" "apps"];
        };
      };
    });
}
