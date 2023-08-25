{ config, lib, pkgs, ... }:

let cfg = config.clement.tools;
in with lib; {
  options.clement.tools = {
    enable = mkEnableOption "Enable tools";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      age
      ansible
      ansible-lint
      dbeaver
      deno
      dig
      file
      gcc
      gh
      gnumake
      go
      graphviz
      jq
      ldns
      nodejs_20
      openssl
      oras
      python311
      restic
      sops
      wget
      whois

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
    ];
  };
}
