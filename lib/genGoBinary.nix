{
  autoPatchelfHook,
  bzip2,
  fetchurl,
  installShellFiles,
  lib,
  stdenvNoCC,
  system,
  unzip,

  name,
  pname ? "${name}-bin",
  version,
  arch,
  aliases ? [],
  commonCompletion ? false,
  buildInputs ? [],
}:
let
  sys = arch.${system} or (throw "unsupported system: ${system}");
  binaryPath = sys.path or name;

  dontUnpack = !builtins.any (suffix: lib.hasSuffix suffix sys.url) [ ".tar.gz" ".tar.xz" ".zip" ];
in stdenvNoCC.mkDerivation {
  inherit pname version;

  src = fetchurl {
    inherit (sys) url sha256;
  };

  sourceRoot = ".";
  inherit dontUnpack buildInputs;
  nativeBuildInputs = [ bzip2 unzip autoPatchelfHook installShellFiles ];

  installPhase = lib.strings.concatStringsSep "\n" (
    [ "mkdir -p $out/bin" ]
    ++ (
      if dontUnpack
      then [
        (
          if lib.hasSuffix ".gz" sys.url then "gzip -dc $src > $out/bin/${name}"
          else if lib.hasSuffix ".bz2" sys.url then "bzip2 -dc $src > $out/bin/${name}"
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