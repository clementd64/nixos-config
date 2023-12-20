{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "talosctl";
  version = "1.6.0";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://github.com/siderolabs/talos/releases/download/v${version}/talosctl-linux-amd64";
      sha256 = "3682def031e9b89e4fe4437b8b7cc9f383781f4c3173be9416cd65bc6e1333e7";
    };
    aarch64-linux = {
      url = "https://github.com/siderolabs/talos/releases/download/v${version}/talosctl-linux-arm64";
      sha256 = "4950b8bdee4a99ef73ad728a869d6e846275f1416f5760a0751465affaec480a";
    };
  };
}