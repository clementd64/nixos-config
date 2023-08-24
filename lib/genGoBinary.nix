{
  autoPatchelfHook,
  fetchurl,
  lib,
  stdenv,
  system,
  unzip,

  name,
  pname ? "${name}-bin",
  version,
  arch
}:
let
  sys = arch.${system} or (throw "unsupported system: ${system}");
  binaryPath = sys.path or name;

  dontUnpack = !builtins.any (suffix: lib.hasSuffix ".tar.gz" sys.url) [ ".tar.gz" ".tar.xz" ".zip" ];
in stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    inherit (sys) url sha256;
  };

  sourceRoot = ".";
  inherit dontUnpack;
  nativeBuildInputs = [ unzip autoPatchelfHook ];

  installPhase =
    if dontUnpack
    then "mkdir -p $out/bin; cp $src $out/bin/${name}; chmod +x $out/bin/${name}"
    else "mkdir -p $out/bin; ls; mv ${binaryPath} $out/bin/${name}";
}