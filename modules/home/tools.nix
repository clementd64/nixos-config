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
      jq
      ldns
      openssl
      python311

      # HashiCorp
      consul-bin
      nomad-bin
      packer-bin
      terraform-bin
      vault-bin
    ]) ++ (with pkgs-unstable; [
      ansible
      ansible-lint
      dbeaver
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
      minikube
      vcluster
    ]);
  };
}
