{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "talosctl";
  version = "1.7.1";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://github.com/siderolabs/talos/releases/download/v${version}/talosctl-linux-amd64";
      sha256 = "fa058caa5dc8d5afa7055682d40950ac3fd45daa701a78ba995bea541315a365";
    };
    aarch64-linux = {
      url = "https://github.com/siderolabs/talos/releases/download/v${version}/talosctl-linux-arm64";
      sha256 = "c3ac9e5c02790e9e19006412f3de80549f45ed7cd212767e058a0dd05b947b9f";
    };
  };
}