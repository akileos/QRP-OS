{ config, lib, pkgs, ... }:

{
  imports = [ ./rpi-common.nix ];
  
  # Pi4 specific kernel
  boot.kernelPackages = pkgs.linuxPackages_rpi4;
  
  # Pi4 hardware support
  hardware.raspberry-pi."4".apply-overlays-dtmerge.enable = true;
  hardware.deviceTree.filter = "*rpi-4-*.dtb";
  
  # Balanced settings for Pi4 (2-8GB RAM)
  boot.kernelParams = [ 
    "cma=64M" 
    "gpu_mem=76"
  ];
  
  # Enable USB3 and hardware acceleration
  hardware.raspberry-pi."4".fkms-3d.enable = true;
  hardware.raspberry-pi."4".audio.enable = true;
  
  # Better audio support
  services.pipewire.enable = lib.mkDefault true;
  services.pipewire.alsa.enable = lib.mkDefault true;
  services.pipewire.pulse.enable = lib.mkDefault true;
}