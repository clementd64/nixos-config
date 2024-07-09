{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "k3s";
  version = "1.30.2+k3s2";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://github.com/k3s-io/k3s/releases/download/v${version}/k3s";
      sha256 = "3b7f74edcc9b4a7649426b6816a7d3d6d76ddf742384ac63b86ee66e230de758";
    };
    aarch64-linux = {
      url = "https://github.com/k3s-io/k3s/releases/download/v${version}/k3s-arm64";
      sha256 = "759822eab4b92e5a36950e94b5810255c0cc145098393a7ea4b695ecef171857";
    };
  };
}
