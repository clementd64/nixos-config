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
      xorg.libX11
      xorg.libXcursor
      xorg.libXext
      xorg.libXi
      xorg.libXinerama
      xorg.libXrandr
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
    version = "1.1.110";

    src = fetchurl {
      name = "factorio-headless-${version}.tar.xz";
      url = "https://factorio.com/get-download/${version}/headless/linux64";
      sha256 = "485fe6db36e5decd7dd0d70e7c97e61f818100fa3e48d87884b287027c7a646a";
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
