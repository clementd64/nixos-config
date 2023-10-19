{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "calicoctl";
  version = "3.26.3";
  aliases = [
    "kubectl-calico"
  ];
  arch = {
    x86_64-linux = {
      url = "https://github.com/projectcalico/calico/releases/download/v${version}/calicoctl-linux-amd64";
      sha256 = "82bd7d12b0f6973f9593fb62f5410ad6a81ff6b79e92f1afd3e664202e8387cf";
    };
    aarch64-linux = {
      url = "https://github.com/projectcalico/calico/releases/download/v${version}/calicoctl-linux-arm64";
      sha256 = "c50272a39658a3b358b33c03fe10d1dde894764413279fecc72d40b95535b398";
    };
  };
}