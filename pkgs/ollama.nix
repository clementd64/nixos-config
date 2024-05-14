{ callPackage, stdenv }:
callPackage ../lib/genGoBinary.nix rec {
  name = "ollama";
  version = "0.1.37";
  buildInputs = [ stdenv.cc.cc ];
  arch = {
    x86_64-linux = {
      url = "https://github.com/jmorganca/ollama/releases/download/v${version}/ollama-linux-amd64";
      sha256 = "2d1f94a15d7d96190a521da16103be70a6e2b8fec81e4bef45d02d12d3b3c79c";
    };
    aarch64-linux = {
      url = "https://github.com/jmorganca/ollama/releases/download/v${version}/ollama-linux-arm64";
      sha256 = "5886ce31637ad13af3d5c60dc0a74d8aa4a9b9903acfd846274b9a051d444108";
    };
  };
}
