{ config, pkgs, lib, ... }:
{
  boot.kernelPackages = pkgs.linuxPackages_latest;

  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];
  };

  nix.gc = lib.mkIf (!config.boot.isContainer) {
    automatic = true;
    dates = "weekly";
    randomizedDelaySec = "45min";
    options = "--delete-older-than 30d";
  };

  time.timeZone = "Europe/Paris";
  console = {
    keyMap = "fr";
  };

  boot.tmp.cleanOnBoot = true;

  networking.useDHCP = false;
  systemd.network = {
    enable = lib.mkIf (!config.boot.isContainer) true;
    wait-online.anyInterface = true;
  };

  programs.fish = {
    enable = true;
    loginShellInit = ''
      set -g fish_greeting
    '';
  };
  environment.shells = with pkgs; [ fish ];

  users.mutableUsers = false;
  users.users.clement = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [ "wheel" ];
  };

  security.sudo = {
    execWheelOnly = true;
    wheelNeedsPassword = false;
  };

  programs.command-not-found.enable = false;
  environment.defaultPackages = lib.mkForce [];

  # remove nscd. cache are already disabled by default so running it is useless
  services.nscd.enable = false;
  system.nssModules = lib.mkForce [];
}
