{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "vcluster";
  version = "0.16.3";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://github.com/loft-sh/vcluster/releases/download/v${version}/vcluster-linux-amd64";
      sha256 = "ad5e8b909f60db8bb864abb9d31221d6767268437d454bb2cd2c78209fcaf642";
    };
    aarch64-linux = {
      url = "https://github.com/loft-sh/vcluster/releases/download/v${version}/vcluster-linux-arm64";
      sha256 = "1b2279205f7494df3d723ece8e46ea93026083077b53d79c2b1fd56d087f86ed";
    };
  };
}