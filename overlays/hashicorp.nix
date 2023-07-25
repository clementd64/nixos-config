prev: final:
let
  hashicorp = final.callPackage ../pkgs/hashicorp.nix {};
in {
  consul-bin = hashicorp.consul-bin;
  nomad-bin = hashicorp.nomad-bin;
  packer-bin = hashicorp.packer-bin;
  terraform-bin = hashicorp.terraform-bin;
  vault-bin = hashicorp.vault-bin;
}