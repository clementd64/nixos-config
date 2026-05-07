{ fetchStaticBinary }:
fetchStaticBinary rec {
  name = "k3s";
  version = "1.36.0+k3s1";
  arch = {
    x86_64-linux = {
      url = "https://github.com/k3s-io/k3s/releases/download/v${version}/k3s";
      sha256 = "efa953454c8f7bf8d9d35c2dad2a76c9bdaac6860d60361629a3a2719009876b";
    };
    aarch64-linux = {
      url = "https://github.com/k3s-io/k3s/releases/download/v${version}/k3s-arm64";
      sha256 = "5a4e4e76ddacb7997384746992439b9a75ed930d8d2b9caf1938571d416d8a0e";
    };
  };
}
