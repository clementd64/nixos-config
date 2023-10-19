{ callPackage }:
callPackage ../lib/genGoBinary.nix rec {
  name = "traefik";
  version = "2.10.5";
  arch = {
    x86_64-linux = {
      url = "https://github.com/traefik/traefik/releases/download/v${version}/traefik_v${version}_linux_amd64.tar.gz";
      sha256 = "38722e4747bf576e4e6bc206d82a67e39c002ccb7855975e05664819f438b08c";
    };
    aarch64-linux = {
      url = "https://github.com/traefik/traefik/releases/download/v${version}/traefik_v${version}_linux_arm64.tar.gz";
      sha256 = "cb78b34df7b785d01110b5af495ba22038f02802421e56001c9580792b1d7b2b";
    };
  };
}