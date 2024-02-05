{ callPackage }:
callPackage ../lib/genGoBinary.nix rec {
  name = "restic";
  version = "0.16.4";
  arch = {
    x86_64-linux = {
      url = "https://github.com/restic/restic/releases/download/v${version}/restic_${version}_linux_amd64.bz2";
      sha256 = "3d4d43c169a9e28ea76303b1e8b810f0dcede7478555fdaa8959971ad499e324";
    };
    aarch64-linux = {
      url = "https://github.com/restic/restic/releases/download/v${version}/restic_${version}_linux_arm64.bz2";
      sha256 = "9d2f44538ea0c6309426cb290d3a6b8b0b85de5de7f1496ff40c843b36bf8a8d";
    };
  };
}