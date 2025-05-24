{ config, lib, pkgs, ... }:

{
  imports = [ ./rpi-common.nix ];
  
  # Pi5 uses latest kernel
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
  
  # Pi5 hardware support
  hardware.deviceTree.filter = lib.mkForce "*rpi-5-*.dtb";
  
  # Aggressive settings for Pi5 (4-8GB RAM)
  boot.kernelParams = [ 
    "cma=128M"
    "gpu_mem=128"
    # Enable performance governor
    "cpufreq.default_governor=performance"
  ];
  
  # Full audio stack for Pi5
  services.pipewire.enable = true;
  services.pipewire.alsa.enable = true;
  services.pipewire.pulse.enable = true;
  services.pipewire.jack.enable = true;  # For low-latency audio
  
  # Enable more services on powerful Pi5
  networking.networkmanager.enable = lib.mkForce true;
  networking.wireless.enable = lib.mkForce false;
  
  # Basic filesystem configuration for nixosConfigurations
  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
    autoResize = true;  # Automatically expand to full SD card size
  };
  
  fileSystems."/boot" = lib.mkDefault {
    device = "/dev/disk/by-label/FIRMWARE";
    fsType = "vfat";
  };
  
  # Basic bootloader configuration for RPi
  boot.loader.grub.enable = lib.mkDefault false;
  boot.loader.generic-extlinux-compatible.enable = lib.mkDefault true;
}