{ config, lib, pkgs, ... }:

{
  imports = [ ./rpi-common.nix ];
  
  # Pi4 specific kernel
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_rpi4;
  
  # Pi4 hardware support
  hardware.deviceTree.filter = lib.mkForce "*rpi-4-*.dtb";
  
  # Balanced settings for Pi4 (2-8GB RAM)
  boot.kernelParams = [ 
    "cma=64M" 
    "gpu_mem=76"
  ];
  
  # Better audio support
  services.pipewire.enable = lib.mkDefault true;
  services.pipewire.alsa.enable = lib.mkDefault true;
  services.pipewire.pulse.enable = lib.mkDefault true;
  
  # Basic filesystem configuration for nixosConfigurations
  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };
  
  fileSystems."/boot" = lib.mkDefault {
    device = "/dev/disk/by-label/FIRMWARE";
    fsType = "vfat";
  };
  
  # Basic bootloader configuration for RPi
  boot.loader.grub.enable = lib.mkDefault false;
  boot.loader.generic-extlinux-compatible.enable = lib.mkDefault true;
}