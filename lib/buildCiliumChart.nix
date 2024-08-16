{
  fetchurl,
  kubernetes-helm,
  lib,
  stdenvNoCC,
  system,
  writeText,
  k8s,

  name,
  version,
  digest,
  values ? {},
  namespace ? "cilium-system",
}:

# Ensure auto tls for hubble is disabled as it provide impure output
assert lib.attrsets.attrByPath [ "hubble" "enabled" ] true values == false
  || lib.attrsets.attrByPath [ "hubble" "tls" "auto" "enabled" ] true values == false
  || lib.attrsets.attrByPath [ "hubble" "tls" "auto" "method" ] "helm" values != "helm";

let
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

  # Ensure that the generated manifests are reproducible
  doCheck = true;
  checkPhase = ''
    ${helmTemplateCmd} > a
    ${helmTemplateCmd} > b
    cmp a b
  '';

  installPhase = ''
    echo '${builtins.toJSON (k8s.manifests.namespace namespace)}' > $out
    ${helmTemplateCmd} >> $out
  '';
}