{ fetchStaticBinary, stdenv }:
fetchStaticBinary rec {
  name = "ollama";
  version = "0.2.1";
  buildInputs = [ stdenv.cc.cc ];
  arch = {
    x86_64-linux = {
      url = "https://github.com/ollama/ollama/releases/download/v${version}/ollama-linux-amd64";
      sha256 = "8a29a80403f67abe0f5b3737767b2a21732409e8e4429098af75474484e43c18";
    };
    aarch64-linux = {
      url = "https://github.com/ollama/ollama/releases/download/v${version}/ollama-linux-arm64";
      sha256 = "6a9080c6f857db9293817845b20a9e35c5e55cef944da6af0abbb6f2f8afb22d";
    };
  };
}
