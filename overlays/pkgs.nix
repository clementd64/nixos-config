prev: final:
let
  factorio = final.callPackage ../pkgs/factorio.nix {};
in {
  factorio = factorio.factorio;
  factorio-env = factorio.factorio-env;
  fluxcd = final.callPackage ../pkgs/kubernetes/fluxcd.nix {};
  flyctl = final.callPackage ../pkgs/flyctl.nix {};
  hashicorp = final.callPackage ../pkgs/hashicorp {};
  kind = final.callPackage ../pkgs/kubernetes/kind.nix {};
  kubectl = final.callPackage ../pkgs/kubernetes/kubectl.nix {};
  kubernetes-helm = final.callPackage ../pkgs/kubernetes/helm.nix {};
  mapshot = factorio.mapshot;
  minikube = final.callPackage ../pkgs/kubernetes/minikube.nix {};
  ollama = final.callPackage ../pkgs/ollama.nix {};
  opentofu = final.callPackage ../pkgs/opentofu.nix {};
  restic = final.callPackage ../pkgs/restic.nix {};
  sops = final.callPackage ../pkgs/sops.nix {};
  talosctl = final.callPackage ../pkgs/kubernetes/talosctl.nix {};
}
