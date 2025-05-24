{ config, lib, pkgs, ... }:

{
  imports = [ ./rpi-common.nix ];
  
  # Pi Zero 2W uses Pi3 kernel (same BCM2710A1 SoC)
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_rpi3;
  
  # Pi Zero 2W hardware support (uses Pi3 device tree)
  hardware.deviceTree.filter = lib.mkForce "*rpi-3-*.dtb";
  
  # Aggressive memory optimization for 512MB RAM
  boot.kernelParams = [ 
    "cma=16M"          # Minimal CMA for GPU (vs 32M on Pi3)
    "gpu_mem=32"       # Minimal GPU memory (vs 64M on Pi3)
    "vm.swappiness=1"  # Avoid swap as much as possible
    "vm.vfs_cache_pressure=500"  # Reduce filesystem cache pressure
    "vm.dirty_ratio=15"          # Reduce dirty page ratio
    "vm.dirty_background_ratio=5" # Reduce background dirty pages
    # Disable unnecessary features to save memory
    "logo.nologo"
    "quiet"
    "loglevel=3"       # Reduce boot verbosity to save memory
  ];
  
  # Disable PipeWire - too memory hungry for Pi Zero 2W
  services.pipewire.enable = lib.mkForce false;
  services.pulseaudio.enable = lib.mkForce true;
  
  # Optimize PulseAudio for low memory
  services.pulseaudio.extraConfig = ''
    # Reduce buffer sizes to save memory
    default-sample-rate = 22050
    default-sample-channels = 1
    default-fragments = 2
    default-fragment-size-msec = 125
  '';
  
  # Disable some resource-heavy services by default
  services.avahi.enable = lib.mkDefault false;  # mDNS discovery
  services.udisks2.enable = lib.mkDefault false; # Auto-mounting
  
  # Use lightweight alternatives where possible
  services.dbus.implementation = lib.mkDefault "broker";  # Lighter than dbus
  
  # Optimize for low memory usage
  services.logind.extraConfig = ''
    # Reduce journal size
    RuntimeMaxUse=16M
    SystemMaxUse=32M
  '';
  
  # Prefer wireless over NetworkManager on Pi Zero 2W (saves memory)
  networking.networkmanager.enable = lib.mkDefault false;
  networking.wireless.enable = lib.mkDefault true;
  
  # Basic filesystem configuration for nixosConfigurations
  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
    options = [ "noatime" "nodiratime" ]; # Reduce disk writes
    autoResize = true;  # Automatically expand to full SD card size
  };
  
  fileSystems."/boot" = lib.mkDefault {
    device = "/dev/disk/by-label/FIRMWARE";
    fsType = "vfat";
  };
  
  # Basic bootloader configuration for RPi
  boot.loader.grub.enable = lib.mkDefault false;
  boot.loader.generic-extlinux-compatible.enable = lib.mkDefault true;
  
  # Reduce boot verbosity to save memory
  boot.consoleLogLevel = 3;
}
