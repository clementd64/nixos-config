{ callPackage }:
callPackage ../lib/genGoBinary.nix rec {
  name = "restic";
  version = "0.17.0";
  arch = {
    x86_64-linux = {
      url = "https://github.com/restic/restic/releases/download/v${version}/restic_${version}_linux_amd64.bz2";
      sha256 = "fec7ade9f12c30bd6323568dbb0f81a3f98a3c86acc8161590235c0f18194022";
    };
    aarch64-linux = {
      url = "https://github.com/restic/restic/releases/download/v${version}/restic_${version}_linux_arm64.bz2";
      sha256 = "f9ad4d91c181da2968ccdecb5238bf872f824fe1e40253f3347c4025192f19c9";
    };
  };
}