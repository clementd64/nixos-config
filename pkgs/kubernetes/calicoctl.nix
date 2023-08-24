{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "calicoctl";
  version = "3.26.1";
  aliases = [
    "kubectl-calico"
  ];
  arch = {
    x86_64-linux = {
      url = "https://github.com/projectcalico/calico/releases/download/v${version}/calicoctl-linux-amd64";
      sha256 = "c8f61c1c8e2504410adaff4a7255c65785fe7805eebfd63340ccd3c472aa42cf";
    };
    aarch64-linux = {
      url = "https://github.com/projectcalico/calico/releases/download/v${version}/calicoctl-linux-arm64";
      sha256 = "bba2fbdd6d2998bca144ae12c2675d65c4fbf51c0944d69b1b2f20e08cd14c22";
    };
  };
}