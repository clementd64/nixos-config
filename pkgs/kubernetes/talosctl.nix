{ fetchStaticBinary }:
fetchStaticBinary rec {
  name = "talosctl";
  version = "1.8.1";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://github.com/siderolabs/talos/releases/download/v${version}/talosctl-linux-amd64";
      sha256 = "c44180a3a4e91325a820464a9bff5ba3e5e86840ca8faa1d2f2e1340ecdd9271";
    };
    aarch64-linux = {
      url = "https://github.com/siderolabs/talos/releases/download/v${version}/talosctl-linux-arm64";
      sha256 = "db684df5beab5a87ed51c2ba2868d8c10268338c9b424a01d3c9af4e3e17a184";
    };
  };
}