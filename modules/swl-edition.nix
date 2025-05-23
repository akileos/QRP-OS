{ config, lib, pkgs, ... }:

with lib;

{
  imports = [ ./ham-radio-base.nix ];

  config = {
    hamRadio = {
      enable = true;
      enableTX = false;  # SWL = receive only
    };

    environment.systemPackages = with pkgs; [
      gqrx
      rtl-sdr
      soapysdr-with-plugins
      cubicsdr
      # Add other RX-only tools
    ];
  };
}
