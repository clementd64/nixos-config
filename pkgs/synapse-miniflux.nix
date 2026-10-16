{ matrix-synapse-unwrapped }:
let
  python = matrix-synapse-unwrapped.python;
in
python.pkgs.buildPythonPackage {
  pname = "synapse-miniflux";
  version = "1.0";
  format = "other";
  dontUnpack = true;
  installPhase = ''
    install -Dm644 ${../hack/synapse-miniflux.py} $out/${python.sitePackages}/synapse_miniflux.py
  '';
}
