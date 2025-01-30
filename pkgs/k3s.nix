{ fetchStaticBinary }:
fetchStaticBinary rec {
  name = "k3s";
  version = "1.31.0+k3s1";
  arch = {
    x86_64-linux = {
      url = "https://github.com/k3s-io/k3s/releases/download/v${version}/k3s";
      sha256 = "a6bef15460b89491e6a60e53fbec29aa20ae44ad02dbdaae9f235c1f27933a62";
    };
    aarch64-linux = {
      url = "https://github.com/k3s-io/k3s/releases/download/v${version}/k3s-arm64";
      sha256 = "e12755a6965a7f50c6d2c62444ef2b6b8c724d0b8900752452fc2bbb1d5fab28";
    };
  };
}
