{ config, pkgs, unstablePkgs, ... } : {

#packages
environment.systemPackages = with pkgs; [
  #term
  starship
  bash
  unrar
  wineWowPackages.full
  networkmanagerapplet
  bat
  brightnessctl
  neovim
  git
  btop
  fzf
  fd
  parted
  gnumake
  #progs
  modrinth-app
  blueberry
  librewolf
  #etc
  tldr
  #DE
  swaybg
  wofi
  playerctl
  wl-clipboard
  grim
  slurp
  #bloat
  fastfetch
  nitch
  #langs/lsps
  nil
  clang-tools
  gcc
] ++ (with unstablePkgs; [
  jdk
]);


fonts.packages = with pkgs; [
  nerd-fonts.meslo-lg
  jetbrains-mono
];

programs.obs-studio = {
enable = false; #disabled, runs heavy background processes
plugins = with pkgs.obs-studio-plugins; [
obs-pipewire-audio-capture
 ];
};

programs.nix-ld.enable = true;

}
