{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "minikube";
  version = "1.31.2";
  arch = {
    x86_64-linux = {
      url = "https://github.com/kubernetes/minikube/releases/download/v${version}/minikube-linux-amd64";
      sha256 = "88a80c051696adaa1a2a0c6aba5fde18176fd5afa87be10617ecaab9cd3a719b";
    };
    aarch64-linux = {
      url = "https://github.com/kubernetes/minikube/releases/download/v${version}/minikube-linux-arm64";
      sha256 = "09f450f753fe15da7e84a955f6b62c05856cef2facf564f8e609445036c8cb22";
    };
  };
}