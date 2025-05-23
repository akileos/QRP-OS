{ config, lib, pkgs, ... }:

with lib;

{
  imports = [ ./qrp-radio-base.nix ];

  config = {
    qrpRadio.enable = true;

    environment.systemPackages = with pkgs; [
      fldigi
      flrig
      wsjtx
      js8call
      gqrx
      # Digital mode specific tools
    ];
  };
}
