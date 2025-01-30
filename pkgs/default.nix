{ callPackage }:
let
  factorio = callPackage ./factorio.nix {};
  qemu-user-static = callPackage ./qemu-user-static.nix {};
in {
  inherit (factorio) factorio factorio-env factorio-headless mapshot;
  inherit (qemu-user-static) qemu-aarch64-static;
  k3s = callPackage ./k3s.nix {};
  proxy64 = callPackage ./proxy64.nix {};
}
