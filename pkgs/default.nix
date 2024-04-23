{ callPackage }:
let
  factorio = callPackage ./factorio.nix {};
in {
  bpftop = callPackage ./bpftop.nix {};
  factorio = factorio.factorio;
  factorio-env = factorio.factorio-env;
  fluxcd = callPackage ./kubernetes/fluxcd.nix {};
  flyctl = callPackage ./flyctl.nix {};
  hashicorp = callPackage ./hashicorp {};
  kind = callPackage ./kubernetes/kind.nix {};
  kubectl = callPackage ./kubernetes/kubectl.nix {};
  kubelet = callPackage ./kubernetes/kubelet.nix {};
  kubernetes-helm = callPackage ./kubernetes/helm.nix {};
  mapshot = factorio.mapshot;
  minikube = callPackage ./kubernetes/minikube.nix {};
  ollama = callPackage ./ollama.nix {};
  opentofu = callPackage ./opentofu.nix {};
  restic = callPackage ./restic.nix {};
  sops = callPackage ./sops.nix {};
  talosctl = callPackage ./kubernetes/talosctl.nix {};
}
