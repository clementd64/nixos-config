{ system, nixpkgs-docker, pkgs-unstable }:
prev: final:
let
  pkgs-docker = import nixpkgs-docker {
    inherit system;
  };
in {
  inherit (pkgs-unstable) docker-compose docker-proxy;
  inherit (pkgs-docker) docker-buildx; # Buildx still affected by Go 1.20.6 regression
  docker = (final.callPackage ../pkgs/docker.nix {}).docker_24_0;
}