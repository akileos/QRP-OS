{ config, lib, pkgs, ... }:

with lib;

{
  imports = [ ./qrp-radio-base.nix ];

  config = {
    qrpRadio.enable = true;

    environment.systemPackages = with pkgs; [
      # CW training and keying
      cw
      # xcwcp might be part of unixcw package
      unixcw
      # Add logging software
      cqrlog
    ];
  };
}