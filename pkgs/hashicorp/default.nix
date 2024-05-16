{
  autoPatchelfHook,
  fetchurl,
  stdenvNoCC,
  system,
  unzip
}:
let
  # Map system to arch
  systemMap = {
    x86_64-linux  = "linux_amd64";
    aarch64-linux = "linux_arm64";
  };

  hashicorpRelease = {
    name,
    version,
    sha256,
    pname ? "${name}-bin"
  }:
    let
      arch = systemMap.${system} or (throw "unsupported system: ${system}");
    in stdenvNoCC.mkDerivation {
      inherit pname version;
      src = fetchurl {
        url = "https://releases.hashicorp.com/${name}/${version}/${name}_${version}_${arch}.zip";
        sha256 = sha256.${system};
      };

      sourceRoot = ".";
      nativeBuildInputs = [ unzip autoPatchelfHook ];

      installPhase = ''
        mkdir -p $out/bin
        mv ${name} $out/bin
      '';
    };

  releases = import ./releases.nix;
in builtins.mapAttrs (name: value: hashicorpRelease (value // { inherit name; })) releases
