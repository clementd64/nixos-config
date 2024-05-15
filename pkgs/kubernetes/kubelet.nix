{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "kubelet";
  version = "1.30.1";
  arch = {
    x86_64-linux = {
      url = "https://dl.k8s.io/release/v${version}/bin/linux/amd64/kubelet";
      sha256 = "87bd6e5de9c0769c605da5fedb77a35c8b764e3bda1632447883c935dcf219d3";
    };
    aarch64-linux = {
      url = "https://dl.k8s.io/release/v${version}/bin/linux/arm64/kubelet";
      sha256 = "c45049b829af876588ec1a30def3884ce77c2c175cd77485d49c78d2064a38fb";
    };
  };
}