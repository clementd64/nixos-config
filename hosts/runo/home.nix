{ config, lib, pkgs, ... }:
{
  clement = {
    fish.enable = true;
    htop.enable = true;
    starship.enable = true;
  };

  home.stateVersion = "23.11";
}
