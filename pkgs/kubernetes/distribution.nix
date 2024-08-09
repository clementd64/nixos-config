{ fetchStaticBinary }:
fetchStaticBinary rec {
  name = "registry";
  version = "2.8.3";
  arch = {
    x86_64-linux = {
      url = "https://github.com/distribution/distribution/releases/download/v${version}/registry_${version}_linux_amd64.tar.gz";
      sha256 = "b1f750ecbe09f38e2143e22c61a25e3da2afe1510d9522859230b480e642ceff";
    };
    aarch64-linux = {
      url = "https://github.com/distribution/distribution/releases/download/v${version}/registry_${version}_linux_arm64.tar.gz";
      sha256 = "7d2252eeeac97dd60fb9b36bebd15b95d7f947c4c82b8e0824cb55233ece9cd0";
    };
  };
}