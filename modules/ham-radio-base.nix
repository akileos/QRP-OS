{ config, lib, pkgs, ... }:

with lib;

{
  options.hamRadio = {
    enable = mkEnableOption "HAM Radio base system";
    
    enableTX = mkOption {
      type = types.bool;
      default = true;
      description = "Enable transmit capabilities";
    };
  };

  config = mkIf config.hamRadio.enable {
    # Audio system
    sound.enable = true;
    hardware.pulseaudio.enable = true;
    
    # USB and serial support for radios
    services.udev.extraRules = ''
      # Common HAM radio interfaces
      SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", MODE="0666"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="05dc", MODE="0666"
    '';
    
    # Essential packages
    environment.systemPackages = with pkgs; [
      minicom
      picocom
      alsa-utils
      pavucontrol
    ];
    
    # User groups for hardware access
    users.groups.dialout = {};
    users.groups.audio = {};
  };
}
