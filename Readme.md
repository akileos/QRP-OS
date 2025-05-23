# HAM Radio NixOS

A lightweight, modular NixOS distribution designed for HAM radio operators.

## Editions

- **SWL Edition**: Receive-only tools for shortwave listening
- **Digimodes Edition**: Digital mode operations (FT8/4, PSK31, etc.)
- **CW Edition**: CW/Morse code tools
- **Full Edition**: Complete HAM radio toolkit

## Building

```bash
# Build specific edition ISO
nix build .#swl-x86-iso
nix build .#digimodes-x86-iso

# Test in VM
nixos-rebuild build-vm --flake .#swl-x86
