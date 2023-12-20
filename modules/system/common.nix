{ pkgs, lib, ... }:
{
  time.timeZone = "Europe/Paris";
  console = {
    keyMap = "fr";
  };

  boot.tmp.cleanOnBoot = true;

  programs.fish.enable = true;
  environment.shells = with pkgs; [ fish ];

  users.mutableUsers = false;
  users.users.clement = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [ "wheel" ];
  };
  security.sudo.wheelNeedsPassword = false;

  programs.command-not-found.enable = false;
  environment.defaultPackages = lib.mkForce [];
}
