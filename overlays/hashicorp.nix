prev: final:
let
  hashicorp = final.callPackage ../pkgs/hashicorp {};
in {
  inherit hashicorp;
}