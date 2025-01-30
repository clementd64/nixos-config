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
      fluxcd
      flyctl
      gcc
      gh
      gnumake
      go
      graphviz
      jq
      kubectl
      kubernetes-helm
      ldns
      nodejs_22
      openssl
      packer
      python312
      python312Packages.requests
      rclone
      restic
      rsync
      sops
      terraform
      unzip
      wget
      whois
      zigpkgs.master
      zls
    ];
  };
}
