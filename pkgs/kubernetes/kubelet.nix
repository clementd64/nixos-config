{ fetchStaticBinary }:
fetchStaticBinary rec {
  name = "kubelet";
  version = "1.30.2";
  arch = {
    x86_64-linux = {
      url = "https://dl.k8s.io/release/v${version}/bin/linux/amd64/kubelet";
      sha256 = "6923abe67ef069afca61c71c585023840426e802b198298055af3a82e11a4e52";
    };
    aarch64-linux = {
      url = "https://dl.k8s.io/release/v${version}/bin/linux/arm64/kubelet";
      sha256 = "72ceb082311b42032827a936f80cd2437b8eee03053d05dbe36ba48585febfb8";
    };
  };
}