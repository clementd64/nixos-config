{
  crane,
  stdenvNoCC,
  system,
  writeShellScript,

  image,
  sha256,
}:
let
  hash = sha256.${system} or (throw "unsupported system: ${system}");
in stdenvNoCC.mkDerivation {
  name = image;

  builder = writeShellScript "fetch-oci-image.sh" ''
    source $stdenv/setup
    mkdir -p $out
    crane export --platform ${{ "x86_64-linux" = "linux/amd64"; "aarch64-linux" = "linux/arm64"; }.${system}} "${image}" - | tar xC $out
    mkdir -p $out/{dev,proc,sys}
  '';

  outputHash = hash;
  outputHashAlgo = "sha256";
  outputHashMode = "recursive";

  nativeBuildInputs = [ crane ];
}
