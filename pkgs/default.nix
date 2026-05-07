{ callPackage }:
let
  factorio = callPackage ./factorio.nix {};
in {
  inherit (factorio) factorio factorio-env factorio-headless mapshot;
  k3s = callPackage ./k3s.nix {};
  proxy64 = callPackage ./proxy64.nix {};
}
