{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  pname = "cilium-cli-bin";
  name = "cilium";
  version = "0.15.6";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://github.com/cilium/cilium-cli/releases/download/v${version}/cilium-linux-amd64.tar.gz";
      sha256 = "0b28aa1782936af5a5a9594dd66251994fd622af0aeb8bac415a700462ff481f";
    };
    aarch64-linux = {
      url = "https://github.com/cilium/cilium-cli/releases/download/v${version}/cilium-linux-arm64.tar.gz";
      sha256 = "6f5ba1cc7d222f7bc33f20d71f0deb180814f03a4f19c93bbf7e3de51dd62889";
    };
  };
}