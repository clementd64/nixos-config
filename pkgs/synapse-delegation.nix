{ matrix-synapse-unwrapped }:
let
  python = matrix-synapse-unwrapped.python;
in
python.pkgs.buildPythonPackage {
  pname = "synapse-delegation";
  version = "1.0";
  format = "other";
  dontUnpack = true;
  installPhase = ''
    install -Dm644 ${../hack/synapse-delegation.py} $out/${python.sitePackages}/synapse_delegation.py
  '';
}
