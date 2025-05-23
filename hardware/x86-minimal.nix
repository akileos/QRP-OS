{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  # Minimal kernel for older hardware
  boot.kernelPackages = pkgs.linuxPackages;
  
  # Essential drivers
  boot.initrd.availableKernelModules = [ 
    "ehci_pci" "ahci" "xhci_pci" "usb_storage" "sd_mod" "sr_mod" 
  ];
  
  # Audio and HAM radio support
  boot.kernelModules = [ "snd-mixer-oss" ];
  
  # HAM radio USB device rules (shared with Pi)
  services.udev.extraRules = ''
    # Common HAM radio interfaces
    SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", GROUP="dialout", MODE="0664"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="05dc", GROUP="dialout", MODE="0664"
    # RTL-SDR dongles
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2838", GROUP="plugdev", MODE="0664"
  '';
  
  # Minimal networking
  networking.wireless.enable = lib.mkDefault true;
  networking.networkmanager.enable = lib.mkDefault false;
}