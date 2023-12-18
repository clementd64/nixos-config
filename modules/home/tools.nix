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
      flyctl
      gcc
      gh
      gnumake
      go
      graphviz
      hashicorp.packer
      hashicorp.terraform
      jq
      ldns
      nodejs_20
      openssl
      oras
      python311
      python311Packages.requests
      rclone
      restic
      sops
      unzip
      wget
      whois
      zigpkgs.master
      zls

      # Kubernetes
      cilium-cli
      fluxcd
      hubble
      kind
      kubectl
      kubernetes-helm
      minikube
      talosctl
    ];
  };
}
