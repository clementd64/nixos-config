{
  system = [
    system/common.nix
    system/docker.nix
    system/xserver.nix
  ];

  home = [
    home/alacritty.nix
    home/dunst.nix
    home/fish.nix
    home/ghostty.nix
    home/git.nix
    home/htop.nix
    home/neovim
    home/rofi.nix
    home/starship
    home/tools.nix
    home/vscode
  ];
}
