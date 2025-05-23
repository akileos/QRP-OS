{ config, lib, pkgs, ... }:

with lib;

{
  imports = [ ./qrp-radio-base.nix ];

  config = {
    qrpRadio = {
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
