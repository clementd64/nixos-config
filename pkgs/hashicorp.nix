{
  autoPatchelfHook,
  fetchurl,
  stdenv,
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
    in stdenv.mkDerivation {
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
in {
  consul-bin = hashicorpRelease {
    name = "consul";
    version = "1.16.0";
    sha256 = {
      x86_64-linux = "c112d1b2ffcfa7d98cde5508bec3bce383ed3650290cc8be3cfe682b79bb13f1";
      aarch64-linux = "e9b926bcd71f53ef0266141338e75c381a76d769756cc1a02b5250bbf6b7195e";
    };
  };

  nomad-bin = hashicorpRelease {
    name = "nomad";
    version = "1.6.1";
    sha256 = {
      x86_64-linux = "e4c01c51c393b266aee4ff184dd97704ae3d838c233a6189425a9f1c31a55f4f";
      aarch64-linux = "67b2b2b62cee102f7436391588f67440d44737b75c3d29dfebec94948928374d";
    };
  };

  packer-bin = hashicorpRelease {
    name = "packer";
    version = "1.9.2";
    sha256 = {
      x86_64-linux = "34fe48d0d5f99670af15d8a3b581db7ce9d08093ce37240d7c7b996de7947275";
      aarch64-linux = "001f0c8e85742bf2c2f9ef751ec1d6b1d2fdf8ea3c1db4b1abb77340c5e28fc8";
    };
  };

  terraform-bin = hashicorpRelease {
    name = "terraform";
    version = "1.5.3";
    sha256 = {
      x86_64-linux = "5ce4e0fc73d42b79f26ebb8c8d192bdbcff75bdc44e3d66895a48945b6ff5d48";
      aarch64-linux = "776c78281c1b517d1e2d9e78b2e60900b8ef9ecd51c4a5d2ffa68f66fea35dd2";
    };
  };

  vault-bin = hashicorpRelease {
    name = "vault";
    version = "1.14.0";
    sha256 = {
      x86_64-linux = "3d5c27e35d8ed43d861e892fc7d8f888f2fda4319a36f344f8c09603fb184b50";
      aarch64-linux = "116ed35f19b3b91a7afc9533f602cd9cdbfbb08e66c785080b0046a034b0a051";
    };
  };
}
