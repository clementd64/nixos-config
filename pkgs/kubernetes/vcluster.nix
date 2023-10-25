{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "vcluster";
  version = "0.16.4";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://github.com/loft-sh/vcluster/releases/download/v${version}/vcluster-linux-amd64";
      sha256 = "6c0bf8b982944bda638b384f4f999c6af541c83d10d778146031d8123514841b";
    };
    aarch64-linux = {
      url = "https://github.com/loft-sh/vcluster/releases/download/v${version}/vcluster-linux-arm64";
      sha256 = "09defa819cf770dd5d1843b3f87f0a850b71acbb1bc50f778c53af405c8b71a7";
    };
  };
}