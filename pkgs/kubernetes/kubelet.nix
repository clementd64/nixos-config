{ fetchStaticBinary }:
fetchStaticBinary rec {
  name = "kubelet";
  version = "1.31.1";
  arch = {
    x86_64-linux = {
      url = "https://dl.k8s.io/release/v${version}/bin/linux/amd64/kubelet";
      sha256 = "50619fff95bdd7e690c049cc083f495ae0e7c66d0cdf6a8bcad298af5fe28438";
    };
    aarch64-linux = {
      url = "https://dl.k8s.io/release/v${version}/bin/linux/arm64/kubelet";
      sha256 = "fbd98311e96b9dcdd73d1688760d410cc70aefce26272ff2f20eef51a7c0d1da";
    };
  };
}