{ config, lib, pkgs, ... }:

{
  imports = [ ./rpi-common.nix ];
  
  # Pi5 uses latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
  
  # Pi5 hardware support
  hardware.raspberry-pi."5".apply-overlays-dtmerge.enable = true;
  hardware.deviceTree.filter = "*rpi-5-*.dtb";
  
  # Aggressive settings for Pi5 (4-8GB RAM)
  boot.kernelParams = [ 
    "cma=128M"
    "gpu_mem=128"
    # Enable performance governor
    "cpufreq.default_governor=performance"
  ];
  
  # Enable all Pi5 features
  hardware.raspberry-pi."5".fkms-3d.enable = true;
  hardware.raspberry-pi."5".audio.enable = true;
  hardware.raspberry-pi."5".pcie.enable = true;
  
  # Full audio stack for Pi5
  services.pipewire.enable = true;
  services.pipewire.alsa.enable = true;
  services.pipewire.pulse.enable = true;
  services.pipewire.jack.enable = true;  # For low-latency audio
  
  # Enable more services on powerful Pi5
  services.networkmanager.enable = lib.mkForce true;
  networking.wireless.enable = lib.mkForce false;
  
  # USB-C power delivery support
  hardware.raspberry-pi."5".usb-c-pd.enable = true;
}