{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "talosctl";
  version = "1.5.1";
  arch = {
    x86_64-linux = {
      url = "https://github.com/siderolabs/talos/releases/download/v${version}/talosctl-linux-amd64";
      sha256 = "7da40e14a07323e2b8a24a5e5499eb02a73bd0e95beca9b2f8bc0d7d956d0f64";
    };
    aarch64-linux = {
      url = "https://github.com/siderolabs/talos/releases/download/v${version}/talosctl-linux-arm64";
      sha256 = "e051b7b7205432752055a4fd27c512df358c47fc189520808c9d299584cddc2d";
    };
  };
}