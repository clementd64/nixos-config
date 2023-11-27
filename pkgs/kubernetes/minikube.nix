{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "minikube";
  version = "1.32.0";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://github.com/kubernetes/minikube/releases/download/v${version}/minikube-linux-amd64";
      sha256 = "1acbb6e0358264a3acd5e1dc081de8d31c697d5b4309be21cba5587cd59eabb3";
    };
    aarch64-linux = {
      url = "https://github.com/kubernetes/minikube/releases/download/v${version}/minikube-linux-arm64";
      sha256 = "77ca98722819e2e9d94925f662f348c3d41c1831c3cd3a77732093d7f509f172";
    };
  };
}