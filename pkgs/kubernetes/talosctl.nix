{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "talosctl";
  version = "1.6.4";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://github.com/siderolabs/talos/releases/download/v${version}/talosctl-linux-amd64";
      sha256 = "9346ae645f8dbcf1d63601c1dbf725d9e0475b225a9c483de872912fb9d87a01";
    };
    aarch64-linux = {
      url = "https://github.com/siderolabs/talos/releases/download/v${version}/talosctl-linux-arm64";
      sha256 = "b1085ca8f86658532cadca71d77a013e203a60a6b16d3726a133e87ba4113ae1";
    };
  };
}