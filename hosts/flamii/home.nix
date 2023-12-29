{ config, lib, pkgs, ... }:
{
  clement = {
    fish.enable = true;
    neovim.enable = true;
  };

  home.stateVersion = "23.11";
}
