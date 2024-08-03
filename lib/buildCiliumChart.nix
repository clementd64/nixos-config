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

# Ensure auto tls for hubble is disabled as it provide impure output
assert lib.attrsets.attrByPath [ "hubble" "enabled" ] true values == false
  || lib.attrsets.attrByPath [ "hubble" "tls" "auto" "enabled" ] true values == false;

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

  helmTemplateCmd = "helm template cilium $src --no-hooks --skip-crds --namespace ${namespace} --values ${valuesFile}";

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

  # Ensure that the generated manifests are the reproducible
  doCheck = true;
  checkPhase = ''
    ${helmTemplateCmd} > a
    ${helmTemplateCmd} > b
    cmp a b
  '';

  installPhase = ''
    touch $out
    ${generateManifest}
    ${helmTemplateCmd} >> $out
  '';
}