{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "flux";
  pname = "fluxcd-bin";
  version = "2.1.0";
  arch = {
    x86_64-linux = {
      url = "https://github.com/fluxcd/flux2/releases/download/v${version}/flux_${version}_linux_amd64.tar.gz";
      sha256 = "fe6d32da40d5f876434e964c46bc07d00af138c560e063fdcfa8f73e37224087";
    };
    aarch64-linux = {
      url = "https://github.com/fluxcd/flux2/releases/download/v${version}/flux_${version}_linux_arm64.tar.gz";
      sha256 = "f259dc0b44395c732f771bab606fb0bcf694c6b480408b3c2cc7253370d6c439";
    };
  };
}