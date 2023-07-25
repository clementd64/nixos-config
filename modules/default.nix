{
  system = [
    system/xserver.nix
    system/docker.nix
    system/common.nix
  ];

  home = [
    home/alacritty.nix
    home/dunst.nix
    home/fish.nix
    home/git.nix
    home/htop.nix
    home/neovim
    home/rofi.nix
    home/ssh-agent.nix
    home/starship.nix
    home/tools.nix
    home/vscode
  ];
}
