My NixOS config
its for my personal computer its aimed for security, practicality, beeing minimal and fast to use
its hardened encrypted flake-based managed with git

how to use
1. git clone github:AwfullyBlank/NixOS_FortKnox
2. cp /etc/nixos/hardware-configuration.nix ~/Nixos_FortKnox/
3. sudo nixos-rebuild switch --flake .#null

dotfiles
cd ~/.config
git clone github:AwfullyBlank/dotfiles

Encryption
certain parts are encrypted therefore it doesnt include a hardware-configuration.nix
use your own hardware config

Key fetures
hardned kernel, overall hardening and firewall
flake based
zsh with highlighting, autocompletion, powerlevel10k,fzf
sway tiling window manager  for modern wayland experience


