{ config, lib, pkgs, ... }:

{
  # Common hostname for all Raspberry Pi devices
  networking.hostName = lib.mkDefault "qrp-pi";
  
  # RPi specific configuration  
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_rpi4;
  
  # Basic device tree support (without hardware.raspberry-pi options for nixosConfigurations)
  hardware.deviceTree = {
    enable = lib.mkDefault true;
    filter = lib.mkDefault "*rpi-*.dtb";
  };
  
  # GPIO access
  users.groups.gpio = {};
  services.udev.extraRules = ''
    SUBSYSTEM=="gpio", KERNEL=="gpiochip[0-9]*", ACTION=="add", PROGRAM="/bin/sh -c 'chown root:gpio /sys/class/gpio/export /sys/class/gpio/unexport ; chmod 220 /sys/class/gpio/export /sys/class/gpio/unexport'"
  '';

  # Raspberry Pi appropriate initrd modules (no SATA/AHCI)
  # Use mkForce to completely override NixOS defaults that include x86 modules
  boot.initrd.availableKernelModules = lib.mkForce [ 
    "mmc_block" "usb_storage" "sd_mod" 
    "bcm2835"  # Pi-specific SD/MMC module
  ];
  
  # Force disable problematic modules that don't exist on ARM/Pi hardware
  # boot.blacklistedKernelModules = [ "ahci" ];
  
  # Ensure no automatic hardware detection includes SATA modules
  boot.initrd.kernelModules = lib.mkForce [ ];

  # Override base-image.nix kernel modules with Pi-compatible ones only
  boot.kernelModules = lib.mkForce [ 
    "snd-usb-audio" "ftdi_sio" "cp210x" 
    "dvb_usb_rtl28xxu"  # RTL-SDR support
  ];

  # Optimize for ARM
  boot.kernelParams = [ "cma=64M" ];
}