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
      restic
      sops

      # Language
      deno
      go
      nodejs_20

      # Kubernetes
      fluxcd
      kind
      kubectl
      kubernetes-helm
      kubevirt # virtctl
      minikube
      talosctl
      vcluster
    ]);
  };
}
