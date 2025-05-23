{ config, lib, pkgs, ... }:

{
  imports = [ 
    ./ham-radio-base.nix 
    ./swl-edition.nix
    ./digimodes-edition.nix
    ./cw-edition.nix
  ];

  config = {
    # Additional full-featured tools
    environment.systemPackages = with pkgs; [
      # Antenna modeling
      xnec2c
      # Contest logging
      tlf
      # Additional utilities
      chirp
      gpredict
    ];
  };
}