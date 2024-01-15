{ callPackage }:
callPackage ../lib/genGoBinary.nix rec {
  name = "restic";
  version = "0.16.3";
  arch = {
    x86_64-linux = {
      url = "https://github.com/restic/restic/releases/download/v${version}/restic_${version}_linux_amd64.bz2";
      sha256 = "aa86e5667c46ab0bdf8ceca80fa3c8775da2bbc18656250a745ac8b042837a70";
    };
    aarch64-linux = {
      url = "https://github.com/restic/restic/releases/download/v${version}/restic_${version}_linux_arm64.bz2";
      sha256 = "7fdc003748c1fa5ff0d87a64aaa8a029927596db53ee09248494aaebe3970179";
    };
  };
}