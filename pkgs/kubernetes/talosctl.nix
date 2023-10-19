{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "talosctl";
  version = "1.5.4";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://github.com/siderolabs/talos/releases/download/v${version}/talosctl-linux-amd64";
      sha256 = "98d28410f27028ee7e23335e1901da00accc071e262fcb343c892e18fa6ec9af";
    };
    aarch64-linux = {
      url = "https://github.com/siderolabs/talos/releases/download/v${version}/talosctl-linux-arm64";
      sha256 = "02ffeea967b65a5337d9c9c1685b13d050f2d2cae8cbc683835ec123431467ac";
    };
  };
}