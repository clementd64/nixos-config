{ fetchStaticBinary }:
fetchStaticBinary rec {
  name = "kubectl";
  version = "1.31.1";
  commonCompletion = true;
  arch = {
    x86_64-linux = {
      url = "https://dl.k8s.io/release/v${version}/bin/linux/amd64/kubectl";
      sha256 = "57b514a7facce4ee62c93b8dc21fda8cf62ef3fed22e44ffc9d167eab843b2ae";
    };
    aarch64-linux = {
      url = "https://dl.k8s.io/release/v${version}/bin/linux/arm64/kubectl";
      sha256 = "3af2451191e27ecd4ac46bb7f945f76b71e934d54604ca3ffc7fe6f5dd123edb";
    };
  };
}