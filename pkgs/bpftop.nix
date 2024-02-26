{
  autoPatchelfHook,
  fetchurl,
  lib,
  elfutils,
  libz,
  stdenv,
  system,
}:
stdenv.mkDerivation {
  pname = "bpftop-bin";
  version = "0.2.0";

  src = fetchurl {
    url = "https://github.com/Netflix/bpftop/releases/download/v0.2.0/bpftop";
    sha256 = "cc2b0f2b2651e48aa04fd6ad7893e2afb2bc69ea6e237627b2531a34903203bb";
  };

  sourceRoot = ".";
  dontUnpack = true;
  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ libz elfutils stdenv.cc.cc ];

  installPhase = lib.strings.concatStringsSep "\n" [
    "mkdir -p $out/bin"
    "cp $src $out/bin/bpftop"
    "chmod +x $out/bin/bpftop"
  ];
}