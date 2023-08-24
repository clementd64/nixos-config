{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "virtctl";
  version = "1.0.0";
  arch = {
    x86_64-linux = {
      url = "https://github.com/kubevirt/kubevirt/releases/download/v${version}/virtctl-v${version}-linux-amd64";
      sha256 = "9c4cf18807d683c6f8c888553b3d711a3e0a40bf48f927fdcf5905440aa416c0";
    };
    aarch64-linux = {
      url = "https://github.com/kubevirt/kubevirt/releases/download/v${version}/virtctl-v${version}-linux-arm64";
      sha256 = "0ec5c93d313c91fad3002e07c5a5c47a6a8cdd1f8f17b0d838f04af9f874b555";
    };
  };
}