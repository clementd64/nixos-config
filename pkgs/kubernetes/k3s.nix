{ fetchStaticBinary }:
fetchStaticBinary rec {
  name = "k3s";
  version = "1.30.3+k3s1";
  arch = {
    x86_64-linux = {
      url = "https://github.com/k3s-io/k3s/releases/download/v${version}/k3s";
      sha256 = "00e9752be22c0e440cee3a8ffd51e2b8c18ef10cea7edf11cc33f37c70bb6385";
    };
    aarch64-linux = {
      url = "https://github.com/k3s-io/k3s/releases/download/v${version}/k3s-arm64";
      sha256 = "00786746ad8b61efc96e3ea9d4dd3315fbd47818d89d8f5cad2be8a17e69b9aa";
    };
  };
}
