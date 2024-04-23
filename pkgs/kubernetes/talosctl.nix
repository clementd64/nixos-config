{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "talosctl";
  version = "1.7.0";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://github.com/siderolabs/talos/releases/download/v${version}/talosctl-linux-amd64";
      sha256 = "b48d94c59d85868ae506eb68e79a60d248b45ed68b3122e75a8b8bcccdc77a28";
    };
    aarch64-linux = {
      url = "https://github.com/siderolabs/talos/releases/download/v${version}/talosctl-linux-arm64";
      sha256 = "c9d6030de0e7b234fae601422cd341dde8cd08069155af719fbcc1bc6d931c15";
    };
  };
}