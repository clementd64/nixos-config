prev: final:
let
  load = path: final.callPackage (import path) {};
in {
  fluxcd = final.callPackage ../pkgs/kubernetes/fluxcd.nix {};
  kind = final.callPackage ../pkgs/kubernetes/kind.nix {};
  kubectl = final.callPackage ../pkgs/kubernetes/kubectl.nix {};
  kubernetes-helm = final.callPackage ../pkgs/kubernetes/helm.nix {};
  minikube = final.callPackage ../pkgs/kubernetes/minikube.nix {};
  talosctl = final.callPackage ../pkgs/kubernetes/talosctl.nix {};
  vcluster = final.callPackage ../pkgs/kubernetes/vcluster.nix {};
  virtctl = final.callPackage ../pkgs/kubernetes/virtctl.nix {};
}