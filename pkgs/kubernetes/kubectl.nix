{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "kubectl";
  version = "1.28.1";
  arch = {
    x86_64-linux = {
      url = "https://dl.k8s.io/release/v${version}/bin/linux/amd64/kubectl";
      sha256 = "e7a7d6f9d06fab38b4128785aa80f65c54f6675a0d2abef655259ddd852274e1";
    };
    aarch64-linux = {
      url = "https://dl.k8s.io/release/v${version}/bin/linux/arm64/kubectl";
      sha256 = "46954a604b784a8b0dc16754cfc3fa26aabca9fd4ffd109cd028bfba99d492f6";
    };
  };
}