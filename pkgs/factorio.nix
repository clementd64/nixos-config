# Wrapper that provide the necessary environment for Factorio to run
{ buildFHSEnv, callPackage }:
let
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

  mapshot-bin = callPackage ../lib/genGoBinary.nix rec {
    name = "mapshot";
    version = "0.0.19";
    arch = {
      x86_64-linux = {
        url = "https://github.com/Palats/mapshot/releases/download/${version}/mapshot-linux";
        sha256 = "02efab8a3397a88aa1c3f233788f6379e8de6675a1d636bc88c82f17b8428e80";
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
}
