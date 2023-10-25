{ callPackage }:
callPackage ../lib/genGoBinary.nix rec {
  name = "restic";
  version = "0.16.1";
  arch = {
    x86_64-linux = {
      url = "https://github.com/restic/restic/releases/download/v${version}/restic_${version}_linux_amd64.bz2";
      sha256 = "68200563fb40d6ba3b6f744c919867bfc6fd6106b6317e55853d37f797b783b5";
    };
    aarch64-linux = {
      url = "https://github.com/restic/restic/releases/download/v${version}/restic_${version}_linux_arm64.bz2";
      sha256 = "5ad984e4bc9cf2b67a414f99c48b2f5621b12efaa1c838e4a6a13a7333641dc7";
    };
  };
}