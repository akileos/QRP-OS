{ config, lib, pkgs, ... }:

{
  imports = [ ./rpi-common.nix ];
  
  # Pi400 uses the same kernel as Pi4
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_rpi4;
  
  # Pi400 hardware support (same as Pi4)
  hardware.deviceTree.filter = lib.mkForce "*rpi-4-*.dtb";
  
  # Pi400 settings - same as Pi4 but optimized for desktop use
  boot.kernelParams = [ 
    "cma=64M" 
    "gpu_mem=128"  # More GPU memory for desktop use
    # Desktop performance optimizations
    "cpufreq.default_governor=ondemand"
  ];
  
  # Full audio stack for Pi400 (desktop use)
  services.pipewire.enable = lib.mkDefault true;
  services.pipewire.alsa.enable = lib.mkDefault true;
  services.pipewire.pulse.enable = lib.mkDefault true;
  services.pipewire.jack.enable = lib.mkDefault true;  # For low-latency audio
  
  # Pi400 is typically used as a desktop, so enable NetworkManager by default
  networking.networkmanager.enable = lib.mkForce true;
  networking.wireless.enable = lib.mkForce false;
  
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
