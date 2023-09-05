{
  autoPatchelfHook,
  bzip2,
  fetchurl,
  installShellFiles,
  lib,
  stdenv,
  system,
  unzip,

  name,
  pname ? "${name}-bin",
  version,
  arch,
  aliases ? [],
  commonCompletion ? false,
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
  nativeBuildInputs = [ bzip2 unzip autoPatchelfHook installShellFiles ];

  installPhase = lib.strings.concatStringsSep "\n" (
    [ "mkdir -p $out/bin" ]
    ++ (
      if dontUnpack
      then [
        (
          if lib.hasSuffix ".bz2" sys.url
          then "bzip2 -dc $src > $out/bin/${name}"
          else "cp $src $out/bin/${name}"
        )
        "chmod +x $out/bin/${name}"
      ]
      else [ "mv ${binaryPath} $out/bin/${name}" ]
    )
    ++ (map (x: "ln -s ${name} $out/bin/${x}") aliases)
    ++ [ "runHook postInstall" ]
  );

  postInstall = lib.optionalString commonCompletion ''
    installShellCompletion --cmd ${name} \
      --bash <($out/bin/${name} completion bash) \
      --fish <($out/bin/${name} completion fish) \
      --zsh <($out/bin/${name} completion zsh)
  '';
}