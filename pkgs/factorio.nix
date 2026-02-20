{
  autoPatchelfHook,
  buildFHSEnv,
  fetchStaticBinary,
  fetchurl,
  stdenvNoCC,
  unzip,
}:
let
  # Wrapper that provide the necessary environment for Factorio to run
  mkFactorioEnv = { name, runScript, extraPackages ? [] }: buildFHSEnv {
    inherit name runScript;
    targetPkgs = pkgs: (with pkgs; [
      alsa-lib
      libGL
      libpulseaudio
      libx11
      libxcursor
      libxext
      libxi
      libxinerama
      libxrandr
    ]) ++ extraPackages;
  };

  mapshot-bin = fetchStaticBinary rec {
    name = "mapshot";
    version = "0.0.22";
    arch = {
      x86_64-linux = {
        url = "https://github.com/Palats/mapshot/releases/download/${version}/mapshot-linux";
        sha256 = "8d636b26791f1fc91cfda73d74bf97f22219d43dc7a6766b4eca91d8c1c418ff";
      };
    };
  };
in {
  # The game must be manually installed/updated in ~/.local/share/factorio
  factorio = mkFactorioEnv {
    name = "factorio";
    runScript = "~/.local/share/factorio/bin/x64/factorio";
  };
  factorio-env = mkFactorioEnv {
    name = "factorio-env";
    runScript = "\${SHELL-bash}";
  };
  mapshot = mkFactorioEnv {
    name = "mapshot";
    extraPackages = [ mapshot-bin ];
    runScript = "mapshot";
  };

  factorio-headless = stdenvNoCC.mkDerivation rec {
    pname = "factorio";
    version = "2.0.10";

    src = fetchurl {
      name = "factorio-headless-${version}.tar.xz";
      url = "https://factorio.com/get-download/${version}/headless/linux64";
      sha256 = "2d7dd212fa6f715218a5e33bad7d593af8998fa7bf7ce727343159ee1f8c23f4";
    };

    dontBuild = true;
    nativeBuildInputs = [ autoPatchelfHook unzip ];

    installPhase = ''
      mkdir -p $out/{bin,usr/share/factorio}
      cp -a data $out/usr/share/factorio
      cp -a bin/x64/factorio $out/bin/factorio
    '';
  };
}
