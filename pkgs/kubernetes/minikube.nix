{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "minikube";
  version = "1.33.1";
  arch = {
    x86_64-linux = {
      url = "https://github.com/kubernetes/minikube/releases/download/v${version}/minikube-linux-amd64";
      sha256 = "386eb267e0b1c1f000f1b7924031557402fffc470432dc23b9081fc6962fd69b";
    };
    aarch64-linux = {
      url = "https://github.com/kubernetes/minikube/releases/download/v${version}/minikube-linux-arm64";
      sha256 = "0b6a17d230b4a605002981f1eba2f5aa3f2153361a1ab000c01e7a95830b40ba";
    };
  };
}