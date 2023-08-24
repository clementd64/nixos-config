{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "vcluster";
  version = "0.15.6";
  arch = {
    x86_64-linux = {
      url = "https://github.com/loft-sh/vcluster/releases/download/v${version}/vcluster-linux-amd64";
      sha256 = "bd5fec6a4c6ace116cece7d847ebc4f44a7808a37db1915a218613275e3ecc24";
    };
    aarch64-linux = {
      url = "https://github.com/loft-sh/vcluster/releases/download/v${version}/vcluster-linux-arm64";
      sha256 = "e7851685d7c3e92c4c919899c106c4ef8656d7ad30f5198d30680ddf0e4c7abf";
    };
  };
}