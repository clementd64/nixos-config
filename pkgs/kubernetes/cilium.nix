{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  pname = "cilium-cli-bin";
  name = "cilium";
  version = "0.15.17";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://github.com/cilium/cilium-cli/releases/download/v${version}/cilium-linux-amd64.tar.gz";
      sha256 = "ed8edbce96ac7921ee75b2fbe42409fbe381e2f8f896c10d13f864cc52e07a43";
    };
    aarch64-linux = {
      url = "https://github.com/cilium/cilium-cli/releases/download/v${version}/cilium-linux-arm64.tar.gz";
      sha256 = "4df6f634512a0e426258fbb83d43c0defabe9d91c81480c040af08fa05b4a989";
    };
  };
}