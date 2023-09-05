{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "vcluster";
  version = "0.15.7";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://github.com/loft-sh/vcluster/releases/download/v${version}/vcluster-linux-amd64";
      sha256 = "dd9138e507456ef4e57e9f64884942b67e9b97783eaf66e22fb33388979db480";
    };
    aarch64-linux = {
      url = "https://github.com/loft-sh/vcluster/releases/download/v${version}/vcluster-linux-arm64";
      sha256 = "c82980de8fc1e11e7463fed4473bed8510c5f80b56ef3dc5bc665221e9b89f5c";
    };
  };
}