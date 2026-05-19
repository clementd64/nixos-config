{ fetchStaticBinary }:
fetchStaticBinary rec {
  name = "alloy";
  version = "1.16.1";
  arch = {
    x86_64-linux = {
      url = "https://github.com/grafana/alloy/releases/download/v${version}/alloy-linux-amd64.zip";
      sha256 = "68fa7b1c75dc701f5bdc5242ce043ddb52f538ede493b7e9fc73226800fbfd3b";
      path = "alloy-linux-amd64";
    };
    aarch64-linux = {
      url = "https://github.com/grafana/alloy/releases/download/v${version}/alloy-linux-arm64.zip";
      sha256 = "35d6fbcbbe93e9aab102f1e9c1f853d89730f5eca75afff0b81460eed570c4a5";
      path = "alloy-linux-arm64";
    };
  };
}
