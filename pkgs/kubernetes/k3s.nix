{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "k3s";
  version = "1.30.0+k3s1";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://github.com/k3s-io/k3s/releases/download/v${version}/k3s";
      sha256 = "e4b85e74d7be314f39e033142973cc53619f4fbaff3639a420312f20dea12868";
    };
    aarch64-linux = {
      url = "https://github.com/k3s-io/k3s/releases/download/v${version}/k3s-arm64";
      sha256 = "a26b1e4cf67850b26db0222017e3dad238fa1f69f88dac2142c783124c28581f";
    };
  };
}
