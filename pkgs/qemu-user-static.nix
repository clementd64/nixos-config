# TODO: generate inside https://github.com/clementd64/qemu-user-static-artifacts
{
  fetchurl,
  lib,
  stdenvNoCC,
  system,
}:
let
  fetchBinary = {
    arch,
    sha256,
  }:
    let
      version = "8.2.5-2";
      checksum = sha256.${system} or (throw "unsupported system: ${system}");
    in stdenvNoCC.mkDerivation {
      inherit version;
      pname = "qemu-${arch}-static";

      src = fetchurl {
        url = "https://github.com/clementd64/qemu-user-static-artifacts/releases/download/v${version}/${system}-qemu-${arch}-static";
        sha256 = checksum;
      };

      dontUnpack = true;

      installPhase = ''
        mkdir -p $out/bin
        cp $src $out/bin/qemu-${arch}-static
        chmod +x $out/bin/qemu-${arch}-static
      '';
    };
in {
  qemu-aarch64-static = fetchBinary {
    arch = "aarch64";
    sha256.x86_64-linux = "2c09179ac192aaebd6b353ed2f71db906054eef85c0b6645e7671f2a6fc13202";
  };
}
