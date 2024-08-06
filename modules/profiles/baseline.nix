{ config, pkgs, lib, ... }:
{
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
    enable = true;
    wait-online.anyInterface = true;
  };

  programs.fish.enable = true;
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

  system.extraSystemBuilderCmds = ''
    ln -sv ${pkgs.path} $out/nixpkgs
  '';

  nix.nixPath = [ "nixpkgs=/run/current-system/nixpkgs" ];
}
