{ fetchStaticBinary }:
fetchStaticBinary rec {
  name = "k3s";
  version = "1.32.3+k3s1";
  arch = {
    x86_64-linux = {
      url = "https://github.com/k3s-io/k3s/releases/download/v${version}/k3s";
      sha256 = "b19216803650b567bf980888dec39035edaf664339c55bc4462f7a003edbef83";
    };
    aarch64-linux = {
      url = "https://github.com/k3s-io/k3s/releases/download/v${version}/k3s-arm64";
      sha256 = "e1704d6dd74332acc8c398d36987663c7d559144b8ce789a83fd0ff1cb40cbaa";
    };
  };
}
