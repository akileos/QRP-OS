{ config, lib, pkgs, ... }:

{
  # RPi specific configuration
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  
  boot.kernelPackages = pkgs.linuxPackages_rpi4;
  
  # Hardware support
  hardware.raspberry-pi."4".apply-overlays-dtmerge.enable = true;
  hardware.deviceTree = {
    enable = true;
    filter = "*rpi-4-*.dtb";
  };
  
  # GPIO access
  users.groups.gpio = {};
  services.udev.extraRules = ''
    SUBSYSTEM=="gpio", KERNEL=="gpiochip[0-9]*", ACTION=="add", PROGRAM="/bin/sh -c 'chown root:gpio /sys/class/gpio/export /sys/class/gpio/unexport ; chmod 220 /sys/class/gpio/export /sys/class/gpio/unexport'"
  '';

  # Optimize for ARM
  boot.kernelParams = [ "cma=64M" ];
}