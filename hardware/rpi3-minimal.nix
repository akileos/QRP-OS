{ config, lib, pkgs, ... }:

{
  imports = [ ./rpi-common.nix ];
  
  # Pi3 specific kernel
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_rpi3;
  
  # Pi3 hardware support
  hardware.deviceTree.filter = lib.mkForce "*rpi-3-*.dtb";
  
  # Conservative settings for Pi3 (1GB RAM)
  boot.kernelParams = [ 
    "cma=32M"
    "gpu_mem=64"
    # Reduce memory pressure
    "vm.swappiness=10"
  ];
  
  # Disable some features to save resources
  services.pipewire.enable = lib.mkForce false;
  services.pulseaudio.enable = lib.mkForce true;
  
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