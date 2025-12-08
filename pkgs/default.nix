{ callPackage }:
let
  factorio = callPackage ./factorio.nix {};
  qemu-user-static = callPackage ./qemu-user-static.nix {};
in {
  inherit (factorio) factorio factorio-env factorio-headless mapshot;
  inherit (qemu-user-static) qemu-aarch64-static;
  proxy64 = callPackage ./proxy64.nix {};
}
