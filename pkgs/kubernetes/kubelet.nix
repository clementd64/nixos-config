{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "kubelet";
  version = "1.30.0";
  arch = {
    x86_64-linux = {
      url = "https://dl.k8s.io/release/v${version}/bin/linux/amd64/kubelet";
      sha256 = "32a32ec3d7e7f8b2648c9dd503ce9ef63b4af1d1677f5b5aed7846fb02d66f18";
    };
    aarch64-linux = {
      url = "https://dl.k8s.io/release/v${version}/bin/linux/arm64/kubelet";
      sha256 = "fa887647422d34f3c7cc5b30fefcf97084d2c3277eff237c5808685ba8e4b15a";
    };
  };
}