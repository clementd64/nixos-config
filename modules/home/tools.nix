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
      nodejs_22
      openssl
      python312
      python312Packages.requests
      rclone
      restic
      rsync
      sops
      unzip
      wget
      whois
      zigpkgs.master
      zls

      # Kubernetes
      fluxcd
      kind
      kubectl
      kubernetes-helm
      minikube
      talosctl
    ];
  };
}
