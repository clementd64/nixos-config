# Wrapper that provide the necessary environment for Factorio to run
# The game must be manually installed/updated in ~/.local/share/factorio
{ buildFHSEnv }:
buildFHSEnv {
  name = "factorio";
  targetPkgs = pkgs: with pkgs; [
    xorg.libX11
    xorg.libXext
    libGL
    xorg.libXinerama
    xorg.libXrandr
    xorg.libXcursor
    libpulseaudio
    alsa-lib
  ];
  runScript = "~/.local/share/factorio/bin/x64/factorio";
}
