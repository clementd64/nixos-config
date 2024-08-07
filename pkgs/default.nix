{ callPackage }:
let
  factorio = callPackage ./factorio.nix {};
  qemu-user-static = callPackage ./qemu-user-static.nix {};
in {
  inherit (factorio) factorio factorio-env mapshot;
  inherit (qemu-user-static) qemu-aarch64-static;
  distribution = callPackage ./kubernetes/distribution.nix {};
  fluxcd = callPackage ./kubernetes/fluxcd.nix {};
  flyctl = callPackage ./flyctl.nix {};
  hashicorp = callPackage ./hashicorp {};
  k3s = callPackage ./kubernetes/k3s.nix {};
  kind = callPackage ./kubernetes/kind.nix {};
  kubectl = callPackage ./kubernetes/kubectl.nix {};
  kubelet = callPackage ./kubernetes/kubelet.nix {};
  kubernetes-helm = callPackage ./kubernetes/helm.nix {};
  minikube = callPackage ./kubernetes/minikube.nix {};
  ollama = callPackage ./ollama.nix {};
  opentofu = callPackage ./opentofu.nix {};
  restic = callPackage ./restic.nix {};
  sops = callPackage ./sops.nix {};
  talosctl = callPackage ./kubernetes/talosctl.nix {};
  workerd = callPackage ./workerd.nix {};
}
