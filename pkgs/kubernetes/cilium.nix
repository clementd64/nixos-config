{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  pname = "cilium-cli-bin";
  name = "cilium";
  version = "0.15.11";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://github.com/cilium/cilium-cli/releases/download/v${version}/cilium-linux-amd64.tar.gz";
      sha256 = "5580835cd4f1e4e0aeaaef26de9887ccdb00803b7ef57f57969a0ceda1656c6c";
    };
    aarch64-linux = {
      url = "https://github.com/cilium/cilium-cli/releases/download/v${version}/cilium-linux-arm64.tar.gz";
      sha256 = "26b4dc17217f6caa1aad50a5e98c69e2256baca6925f8286cad6eeb09a5370d8";
    };
  };
}