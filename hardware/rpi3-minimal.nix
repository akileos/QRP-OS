{ config, lib, pkgs, ... }:

{
  imports = [ ./rpi-common.nix ];
  
  # Pi3 specific kernel
  boot.kernelPackages = pkgs.linuxPackages_rpi3;
  
  # Pi3 hardware support
  hardware.raspberry-pi."3".apply-overlays-dtmerge.enable = true;
  hardware.deviceTree.filter = "*rpi-3-*.dtb";
  
  # Conservative settings for Pi3 (1GB RAM)
  boot.kernelParams = [ 
    "cma=32M"
    "gpu_mem=64"
    # Reduce memory pressure
    "vm.swappiness=10"
  ];
  
  # Disable some features to save resources
  services.pipewire.enable = false;
  sound.enable = true;
  hardware.pulseaudio.enable = true;
}