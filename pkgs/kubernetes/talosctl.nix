{ fetchStaticBinary }:
fetchStaticBinary rec {
  name = "talosctl";
  version = "1.7.6";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://github.com/siderolabs/talos/releases/download/v${version}/talosctl-linux-amd64";
      sha256 = "a40e3dfe0437bdd4192e62c94d049c691ff1d0380b95338dbdbed5b8b0700ff6";
    };
    aarch64-linux = {
      url = "https://github.com/siderolabs/talos/releases/download/v${version}/talosctl-linux-arm64";
      sha256 = "4c52d1db65e3e12d435131dfeff6d34b7b87b61e0115c7aad6dc3f1a5596ed41";
    };
  };
}