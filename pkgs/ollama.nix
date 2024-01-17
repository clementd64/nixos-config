{ callPackage, stdenv }:
callPackage ../lib/genGoBinary.nix rec {
  name = "ollama";
  version = "0.1.20";
  buildInputs = [ stdenv.cc.cc ];
  arch = {
    x86_64-linux = {
      url = "https://github.com/jmorganca/ollama/releases/download/v${version}/ollama-linux-amd64";
      sha256 = "5d1e25621ee4e7202d914ab0c237993a749d3fea9aac19345e8cd6c83f6e05a1";
    };
    aarch64-linux = {
      url = "https://github.com/jmorganca/ollama/releases/download/v${version}/ollama-linux-arm64";
      sha256 = "cf3850d0ba7ba47a8b25207952c32c6fdf995df95b763819a04ce45c71c38a5a";
    };
  };
}
