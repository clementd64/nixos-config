{ callPackage }:
callPackage ../../lib/fetchStaticBinary.nix rec {
  name = "talosctl";
  version = "1.7.5";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://github.com/siderolabs/talos/releases/download/v${version}/talosctl-linux-amd64";
      sha256 = "285a8d8d2a0601e4e9ff55972afb9bc0b4f23745d56dfa96e10cc3bafa13de26";
    };
    aarch64-linux = {
      url = "https://github.com/siderolabs/talos/releases/download/v${version}/talosctl-linux-arm64";
      sha256 = "a28a0049a143c38da29d2c4a6ba41dbb8a0b53ef5a9d1a528126f4c4cf651224";
    };
  };
}