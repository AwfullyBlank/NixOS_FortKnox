{ config, pkgs, ... }:

{
imports =
[ 
  ./hardware-configuration.nix
];

nix.settings.experimental-features = [ "nix-command" "flakes" ];


networking.hostName = "nixos"; 
#networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

#services.power-profiles-daemon.enable = true;

# Enable networking
networking.networkmanager = {
enable = true;
  };

#Fail2ban
services.fail2ban = {
    enable = true;
   # Ban IP after 5 failures
    maxretry = 5;
    ignoreIP = [
      # Whitelist some subnets
      "10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/16"
      "8.8.8.8" # whitelist a specific IP
      "nixos.wiki" # resolve the IP via DNS
    ];
    bantime = "24h"; # Ban IPs for one day on the first ban
    bantime-increment = {
      enable = true; # Enable increment of bantime after each violation
      formula = "ban.Time * math.exp(float(ban.Count+1)*banFactor)/math.exp(1*banFactor)";
      #multipliers = "1 2 4 8 16 32 64";
      maxtime = "168h"; # Do not ban for more than 1 week
      overalljails = true; # Calculate the bantime based on all the violations
    };
    jails = {
      apache-nohome-iptables.settings = {
        # Block an IP address if it accesses a non-existent
        # home directory more than 5 times in 10 minutes,
        # since that indicates that it's scanning.
        filter = "apache-nohome";
        action = ''iptables-multiport[name=HTTP, port="http,https"]'';
        logpath = "/var/log/httpd/error_log*";
        backend = "auto";
        findtime = 600;
        bantime  = 600;
        maxretry = 5;
      };
    };
  };

#SSH
services.openssh = {
enable = false;
ports = [ 22 ];
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
programs.nix-ld.enable = true;

boot = {
#Bootloader.
loader.systemd-boot.enable = true;
loader.efi.canTouchEfiVariables = true;

#ntfs
supportedFilesystems = ["ntfs"];

kernelPackages = pkgs.linuxPackages_latest;

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

services.flatpak.enable = false;

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
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = false;
  };

  # Configure console keymap
  console.keyMap = "no";

  services.printing.enable = false;
  services.pipewire.jack.enable = false;

services.dbus.enable = true;

users.users.null = {
isNormalUser = true;
description = "null";
shell = pkgs.zsh;
extraGroups = [ "networkmanager" "wheel" "video" "kvm" ];
};

nixpkgs.config.allowUnfree = true;

#packages, pkgs, PKGS
environment.systemPackages = with pkgs; [
qemu
quickemu
swtpm
OVMF
swaybg
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
waybar
#term
btop
neovim
alacritty
git
parted
#games
modrinth-app
#progs
thunderbird
firefox
librewolf
teams-for-linux
discord-ptb
obsidian
davinci-resolve
#langs/lsp
lua-language-server
clang
clang-tools
lua
jdk
];

#fonts
fonts.packages = with pkgs; [
nerdfonts
];

#steam
programs.steam = {
  enable = false;
  remotePlay.openFirewall = false; # Open ports in the firewall for Steam Remote Play
  dedicatedServer.openFirewall = false; # Open ports in the firewall for Source Dedicated Server
  localNetworkGameTransfers.openFirewall = false; # Open ports in the firewall for Steam Local Network Game Transfers
};

#obs
programs.obs-studio = {
enable = true;
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
};

#sway
programs.sway.enable = true;
programs.sway.wrapperFeatures.gtk = false;

#hyprland
programs.hyprland = {
enable = false;
xwayland.enable = false;
};

environment.variables.MANPAGER = "nvim +Man!";

system.stateVersion = "24.11";
}
