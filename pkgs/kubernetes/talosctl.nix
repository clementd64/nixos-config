{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "talosctl";
  version = "1.7.2";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://github.com/siderolabs/talos/releases/download/v${version}/talosctl-linux-amd64";
      sha256 = "3d7d52a1fa79a49817630174f7078279c1f5ce825351f63b976e967ce17ee8e0";
    };
    aarch64-linux = {
      url = "https://github.com/siderolabs/talos/releases/download/v${version}/talosctl-linux-arm64";
      sha256 = "78cb0a19fca48120c5536a4599f4d0083e8553f17e42209d19c9ae9cf413d2b8";
    };
  };
}