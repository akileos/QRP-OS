{ config, lib, pkgs, ... }:

with lib;

{
  imports = [ ./ham-radio-base.nix ];

  config = {
    hamRadio.enable = true;

    environment.systemPackages = with pkgs; [
      # CW training and keying
      cw
      xcwcp
      unixcw
      # Add logging software
      cqrlog
    ];
  };
}