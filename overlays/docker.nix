{ system, nixpkgs-docker }:
prev: final:
let
  pkgs-docker = import nixpkgs-docker {
    inherit system;
  };
in {
  # Buildx still affected by Go 1.20.6 regression
  inherit (pkgs-docker) docker-buildx;
}