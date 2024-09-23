{ fetchStaticBinary }:
fetchStaticBinary rec {
  name = "restic";
  version = "0.17.1";
  arch = {
    x86_64-linux = {
      url = "https://github.com/restic/restic/releases/download/v${version}/restic_${version}_linux_amd64.bz2";
      sha256 = "bdfaf16fe933136e3057e64e28624f2e0451dbd47e23badb2d37dbb60fdb6a70";
    };
    aarch64-linux = {
      url = "https://github.com/restic/restic/releases/download/v${version}/restic_${version}_linux_arm64.bz2";
      sha256 = "aa9d86ac5f261f6a8295d5503bb27761ba7fe1fc1cf26fa52e7ab249b9a04716";
    };
  };
}