{ callPackage }:
callPackage ../lib/genGoBinary.nix rec {
  name = "traefik";
  version = "2.10.4";
  arch = {
    x86_64-linux = {
      url = "https://github.com/traefik/traefik/releases/download/v${version}/traefik_v${version}_linux_amd64.tar.gz";
      sha256 = "37befba9710120b260582cd91ae817b4a82292711c203f55f3f53b88f14ef9c7";
    };
    aarch64-linux = {
      url = "https://github.com/traefik/traefik/releases/download/v${version}/traefik_v${version}_linux_arm64.tar.gz";
      sha256 = "852a31212a09c6262ae2e571ebc4319d824cc942c1eb62546d500e0ffbcab4f3";
    };
  };
}