{ config, lib, pkgs, pkgs-unstable, ... }:

let cfg = config.clement.tools;
in with lib; {
  options.clement.tools = {
    enable = mkEnableOption "Enable tools";
  };

  config = mkIf cfg.enable {
    home.packages = (with pkgs; [
      dig
      gcc
      gnumake
      graphviz
      jq
      ldns
      openssl
      python311
      wget
      whois
      restic

      # Kubernetes
      calicoctl
      cilium-cli
      fluxcd
      kind
      kubectl
      kubernetes-helm
      minikube
      talosctl
      vcluster
      virtctl

      # HashiCorp
      hashicorp.boundary
      hashicorp.consul
      hashicorp.nomad
      hashicorp.packer
      hashicorp.terraform
      hashicorp.vault
      hashicorp.waypoint
    ]) ++ (with pkgs-unstable; [
      age
      ansible
      ansible-lint
      dbeaver
      gh
      sops

      # Language
      deno
      go
      nodejs_20
    ]);
  };
}
