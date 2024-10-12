{ callPackage }:
let
  factorio = callPackage ./factorio.nix {};
  hashicorp = callPackage ./hashicorp {};
  qemu-user-static = callPackage ./qemu-user-static.nix {};
in {
  inherit (factorio) factorio factorio-env factorio-headless mapshot;
  inherit (hashicorp) packer terraform;
  inherit (qemu-user-static) qemu-aarch64-static;
  distribution = callPackage ./kubernetes/distribution.nix {};
  fluxcd = callPackage ./kubernetes/fluxcd.nix {};
  flyctl = callPackage ./flyctl.nix {};
  k3s = callPackage ./kubernetes/k3s.nix {};
  kind = callPackage ./kubernetes/kind.nix {};
  kubectl = callPackage ./kubernetes/kubectl.nix {};
  kubelet = callPackage ./kubernetes/kubelet.nix {};
  kubernetes-helm = callPackage ./kubernetes/helm.nix {};
  minikube = callPackage ./kubernetes/minikube.nix {};
  opentofu = callPackage ./opentofu.nix {};
  proxy64 = callPackage ./proxy64.nix {};
  restic = callPackage ./restic.nix {};
  sops = callPackage ./sops.nix {};
  talosctl = callPackage ./kubernetes/talosctl.nix {};
  workerd = callPackage ./workerd.nix {};
}
