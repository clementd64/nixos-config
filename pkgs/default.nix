{ callPackage }:
let
  factorio = callPackage ./factorio.nix {};
in {
  inherit (factorio) factorio factorio-env factorio-headless mapshot;
  proxy64 = callPackage ./proxy64.nix {};
}
