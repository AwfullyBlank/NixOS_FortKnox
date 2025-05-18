{ config, pkgs, ... }:

{
imports =
[ 
  ./hardware-configuration.nix
];

nix.settings.experimental-features = [ "nix-command" "flakes" ];


networking.hostName = "nixos"; 


# Enable networking
networking.networkmanager = {
enable = true;
  };

#Fail2ban
services.fail2ban = {
    enable = true;
    maxretry = 5;
    ignoreIP = [
      # Whitelist some subnets
      #"10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/16"
      #"8.8.8.8" # whitelist a specific IP
      "nixos.wiki" # resolve the IP via DNS
    ];
    bantime = "24h";
    bantime-increment = {
      enable = true; # Enable increment of bantime after each violation
      formula = "ban.Time * math.exp(float(ban.Count+1)*banFactor)/math.exp(1*banFactor)";
      maxtime = "168h";
      overalljails = true; # Calculate the bantime based on all the violations
    };
  };

#SSH
services.openssh = {
enable = false;
passwordAuthentication = true;
useDns = true;
permitRootLogin = "no";
};

  #firewall
  networking.firewall = {
  enable = true;
  allowedTCPPorts = [ 3478 80 443 51820 ];# SSH22 UDP3478 HTTP80, HTTPS443, VPNWireGuard51820 DHCP67 DNS53
  };   

#helps with binaries since NixOS FHS diff  
programs.nix-ld.enable = false;

boot = {
loader.systemd-boot.enable = true;
loader.efi.canTouchEfiVariables = true;

#ntfs
supportedFilesystems = ["ntfs"];

kernelPackages = pkgs.linuxPackages_hardened;


#harned kernel
kernel.sysctl = {
 "kernel.unprivileged_userns_clone" = 0; #no unprivleged namespace creation
 "kernel.kptr_restrict" = 2; #no you dont get to see my kernel pointers
 "kernel.dmesg_restrict" = 1; #no normal users see dmesg log
 "fs.protected_hardlinks" = 1; #no unsafe hardlink that escalate privlage
 "fs.protected_symlinks" = 1; # protected symlinks
 "kernel.randomize_va_space" = 2; # Full ASLR (Address Space Layout Randomization)
 "fs.suid_dumpable" = 0; # no core dumps from SUID progs
 };
};


security.protectKernelImage = true;
security.lockKernelModules = true;


  # Set your time zone.
  time.timeZone = "Europe/Oslo";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nb_NO.UTF-8";
    LC_IDENTIFICATION = "nb_NO.UTF-8";
    LC_MEASUREMENT = "nb_NO.UTF-8";
    LC_MONETARY = "nb_NO.UTF-8";
    LC_NAME = "nb_NO.UTF-8";
    LC_NUMERIC = "nb_NO.UTF-8";
    LC_PAPER = "nb_NO.UTF-8";
    LC_TELEPHONE = "nb_NO.UTF-8";
    LC_TIME = "nb_NO.UTF-8";
  };


#bluetooth
hardware = {
bluetooth.enable = true;
bluetooth.powerOnBoot = true;
};


#enable openGL
hardware.graphics = {
  enable = true;
  enable32Bit = true;
  };


  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    jack.enable = false;
    alsa.enable = true;
    alsa.support32Bit = false;
    pulse.enable = true; #for quickemu sound
  };


  # Configure console keymap
  console.keyMap = "no";

services = {
printing.enable = false;
avahi.enable = false;
dbus.enable = true;
};

users.users.null = {
isNormalUser = true;
description = "null";
shell = pkgs.zsh;
extraGroups = [ "networkmanager" "wheel" "video" "kvm" ];
};


nixpkgs.config.allowUnfree = true;


#packages, pkgs, PKGS
environment.systemPackages = with pkgs; [
quickemu
wofi
i3blocks
acpi
playerctl
blueberry
feh
unzip
fastfetch
wl-clipboard
grim
slurp
#term
htop
neovim
fzf
fd
alacritty
parted
#games
modrinth-app
#progs
firefox
librewolf
#obsidian
#langs/lsp
lua-language-server
clang
clang-tools
lua
jdk
nil
];

#fonts
fonts.packages = with pkgs; [
nerdfonts
];

#git
programs.git = {
  enable = true;
};


#obs
programs.obs-studio = {
enable = false;
plugins = with pkgs.obs-studio-plugins; [
obs-pipewire-audio-capture
 ];
};


#zsh
programs.zsh = {
enable = true;
enableCompletion = true;
autosuggestions.enable = true;
syntaxHighlighting.enable = true;
promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
shellInit = ''
cdf() {
  cd "$(fd --type d --hidden --exclude .git | fzf)"
}

nvimf() {
 nvim "$(fd --type f --hidden --exclude .git | fzf)"
}

fehf() {
feh "$(fd --type f --exclude .git | fzf )"
}

export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  '';
};


#sway
programs.sway.enable = true;
programs.sway.wrapperFeatures.gtk = true;


environment.variables.MANPAGER = "nvim +Man!";


system.stateVersion = "24.11";
}
