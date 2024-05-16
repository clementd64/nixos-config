{ callPackage }:
callPackage ../../lib/genGoBinary.nix rec {
  name = "helm";
  version = "3.15.0";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://get.helm.sh/helm-v${version}-linux-amd64.tar.gz";
      sha256 = "a74747ac40777b86d3ff6f1be201504bba65ca46cd68b5fe25d3c394d0dcf745";
      path = "linux-amd64/helm";
    };
    aarch64-linux = {
      url = "https://get.helm.sh/helm-v${version}-linux-arm64.tar.gz";
      sha256 = "c3b0281fca4c030548211dd6e9b032ee0a9fc53eab614f6acbaff631682ce808";
      path = "linux-arm64/helm";
    };
  };
}