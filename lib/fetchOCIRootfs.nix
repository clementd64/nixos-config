{
  crane,
  stdenvNoCC,
  system,
  writeShellScript,
  image,
  sha256,
}:
let
  platform = {
    x86_64-linux = "linux/amd64";
    aarch64-linux = "linux/arm64";
  }.${system} or (throw "unsupported system: ${system}");

  hash = sha256.${system} or (throw "missing hash for system: ${system}");
in stdenvNoCC.mkDerivation {
  name = "oci-rootfs";

  builder = writeShellScript "fetch-oci-image.sh" ''
    source "$stdenv/setup"
    set -euo pipefail
    mkdir -p "$out"
    crane export \
      --platform "${platform}" \
      "${image}" - |
      tar --extract --directory="$out" --no-same-owner
    mkdir -p "$out"/{dev,proc,sys,run,tmp,var/tmp}
  '';

  nativeBuildInputs = [ crane ];

  outputHash = hash;
  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
}