prev: final:
let
  factorio = final.callPackage ../pkgs/factorio.nix {};
in {
  cilium-cli = final.callPackage ../pkgs/kubernetes/cilium.nix {};
  factorio = factorio.factorio;
  factorio-env = factorio.factorio-env;
  fluxcd = final.callPackage ../pkgs/kubernetes/fluxcd.nix {};
  flyctl = final.callPackage ../pkgs/flyctl.nix {};
  hashicorp = final.callPackage ../pkgs/hashicorp {};
  hubble = final.callPackage ../pkgs/kubernetes/hubble.nix {};
  kind = final.callPackage ../pkgs/kubernetes/kind.nix {};
  kubectl = final.callPackage ../pkgs/kubernetes/kubectl.nix {};
  kubernetes-helm = final.callPackage ../pkgs/kubernetes/helm.nix {};
  mapshot = factorio.mapshot;
  minikube = final.callPackage ../pkgs/kubernetes/minikube.nix {};
  opentofu = final.callPackage ../pkgs/opentofu.nix {};
  oras = final.callPackage ../pkgs/oras.nix {};
  restic = final.callPackage ../pkgs/restic.nix {};
  sops = final.callPackage ../pkgs/sops.nix {};
  talosctl = final.callPackage ../pkgs/kubernetes/talosctl.nix {};
  traefik = final.callPackage ../pkgs/traefik.nix {};
}
