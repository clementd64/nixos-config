{ fetchStaticBinary }:
fetchStaticBinary rec {
  name = "minikube";
  version = "1.34.0";
  arch = {
    x86_64-linux = {
      url = "https://github.com/kubernetes/minikube/releases/download/v${version}/minikube-linux-amd64";
      sha256 = "c4a625f9b4a4523e74b745b6aac8b0bf45062472be72cd38a23c91ec04d534c9";
    };
    aarch64-linux = {
      url = "https://github.com/kubernetes/minikube/releases/download/v${version}/minikube-linux-arm64";
      sha256 = "fbe55f563ac33328320d64c319f635386fe020eedf25cba8ebf3850048deb7ae";
    };
  };
}