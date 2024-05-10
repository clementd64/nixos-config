{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "minikube";
  version = "1.33.0";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://github.com/kubernetes/minikube/releases/download/v${version}/minikube-linux-amd64";
      sha256 = "4bfdc17f0dce678432d5c02c2a681c7a72921cb72aa93ccc00c112070ec5d2bc";
    };
    aarch64-linux = {
      url = "https://github.com/kubernetes/minikube/releases/download/v${version}/minikube-linux-arm64";
      sha256 = "d7afb43f87190331b2aee451eef0bae699c93d0acb7b57404cc6b6d3698033a7";
    };
  };
}