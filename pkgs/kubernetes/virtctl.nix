{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "virtctl";
  version = "1.0.1";
  aliases = [
    "kubectl-virt"
  ];
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://github.com/kubevirt/kubevirt/releases/download/v${version}/virtctl-v${version}-linux-amd64";
      sha256 = "386b50fb83c6babb5d4ec2dc4251fac2e41c487bf493c9e664a940de045615e0";
    };
    aarch64-linux = {
      url = "https://github.com/kubevirt/kubevirt/releases/download/v${version}/virtctl-v${version}-linux-arm64";
      sha256 = "2441607bf268b915a8f5e2b174a9e147f98a39ce038a07731082d0aa41c6badb";
    };
  };
}