{ fetchStaticBinary }:
fetchStaticBinary rec {
  name = "talosctl";
  version = "1.8.0";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://github.com/siderolabs/talos/releases/download/v${version}/talosctl-linux-amd64";
      sha256 = "e15f78aaf08b613c797ef350051b26271609890631ce51e50907f6348ac2d823";
    };
    aarch64-linux = {
      url = "https://github.com/siderolabs/talos/releases/download/v${version}/talosctl-linux-arm64";
      sha256 = "ab0880cbc0da9566b4d0d0dbaf9cef5a567d03fa282f95d3de22e03989937c73";
    };
  };
}