{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "talosctl";
  version = "1.5.5";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://github.com/siderolabs/talos/releases/download/v${version}/talosctl-linux-amd64";
      sha256 = "80a9e324564eeb448b228b7345cfb523a156d6362f994d7a557ca0ae353552e7";
    };
    aarch64-linux = {
      url = "https://github.com/siderolabs/talos/releases/download/v${version}/talosctl-linux-arm64";
      sha256 = "95dd4bd61c97aa00d942fcdce783f60fa82579d02192705a3c85e9ecf57573f9";
    };
  };
}