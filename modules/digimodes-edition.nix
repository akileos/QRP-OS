{ config, lib, pkgs, ... }:

with lib;

{
  imports = [ ./ham-radio-base.nix ];

  config = {
    hamRadio.enable = true;

    environment.systemPackages = with pkgs; [
      fldigi
      flrig
      wsjt-x
      js8call
      gqrx
      # Digital mode specific tools
    ];
  };
}
