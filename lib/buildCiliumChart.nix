{
  fetchurl,
  kubernetes-helm,
  lib,
  stdenvNoCC,
  system,
  writeText,

  name,
  version,
  digest,
  values ? {},
  namespace ? "cilium-system",
}:

let
  generateManifest = if namespace != "kube-system" then ''
    cat >> $out <<EOF
    ---
    apiVersion: v1
    kind: Namespace
    metadata:
      name: ${namespace}
    EOF
  '' else "";

  valuesFile = writeText "values.yaml" (builtins.toJSON values);

in stdenvNoCC.mkDerivation {
  inherit version;
  pname = "cilium-manifests.yaml";

  src = fetchurl {
    url = "https://helm.cilium.io/cilium-${version}.tgz";
    sha256 = digest;
  };

  sourceRoot = ".";
  dontUnpack = true;
  nativeBuildInputs = [ kubernetes-helm ];

  installPhase = ''
    touch $out
    ${generateManifest}
    helm template cilium $src --no-hooks --skip-crds --namespace ${namespace} --values ${valuesFile} >> $out
  '';
}