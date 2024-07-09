{ callPackage }:
callPackage ../lib/genGoBinary.nix rec {
  name = "restic";
  version = "0.16.5";
  arch = {
    x86_64-linux = {
      url = "https://github.com/restic/restic/releases/download/v${version}/restic_${version}_linux_amd64.bz2";
      sha256 = "f1a9c39d396d1217c05584284352f4a3bef008be5d06ce1b81a6cf88f6f3a7b1";
    };
    aarch64-linux = {
      url = "https://github.com/restic/restic/releases/download/v${version}/restic_${version}_linux_arm64.bz2";
      sha256 = "41cc6ad3ac5e99ee088011f628fafcb4fa1e4d3846be2333e5c2a3f6143cd0c1";
    };
  };
}