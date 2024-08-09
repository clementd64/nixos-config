{ config, lib, pkgs, ... }:

with lib; {
  options.clement.kubelet.sysctls.enable = mkEnableOption "kubelet sysctls";

  config = mkIf config.clement.kubelet.sysctls.enable {
    # Required for kubelet as nspawn can't override it
    boot.kernel.sysctl = {
      "vm.panic_on_oom" = mkForce "0";
      "vm.overcommit_memory" = mkForce "1";
      "kernel.panic" = mkForce "10";
      "kernel.panic_on_oops" = mkForce "1";
    };
  };
}
