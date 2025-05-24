# QRP Radio OS

A lightweight, modular NixOS distribution designed for QRP and HAM radio operators.

## Overview

QRP Radio OS is a specialized Linux distribution built on NixOS, designed specifically for amateur radio operators. It provides four different editions optimized for different aspects of amateur radio operation, from simple shortwave listening to full-featured contest stations.

## Editions

### 🎧 SWL Edition (Shortwave Listening)
*Receive-only tools for shortwave listening and monitoring*

**Core Applications:**
- **GQRX** - SDR receiver with waterfall display
- **RTL-SDR** - Software defined radio tools
- **SoapySDR** - SDR abstraction library with plugins
- **CubicSDR** - Cross-platform SDR application

**Use Cases:**
- Shortwave listening
- Scanner monitoring
- SDR experimentation
- Receive-only operations

### 📡 Digimodes Edition
*Digital mode operations (FT8/4, PSK31, RTTY, etc.)*

**Core Applications:**
- **WSJT-X** - Weak signal digital modes (FT8, FT4, MSK144, etc.)
- **JS8Call** - JS8 keyboard-to-keyboard messaging
- **Fldigi** - Digital modem program (PSK31, RTTY, CW, etc.)
- **Flrig** - Rig control program
- **GQRX** - SDR receiver

**Use Cases:**
- FT8/FT4 weak signal communication
- PSK31 keyboard chat
- Digital contest operation
- Microwave EME communication

### ⚡ CW Edition
*CW/Morse code tools and training*

**Core Applications:**
- **CW** - Morse code practice and keying
- **UnixCW** - Complete CW training suite (xcwcp, cw, cwcp)
- **CQRLog** - Advanced logging software
- Basic rig control tools

**Use Cases:**
- CW training and practice
- QRP CW operation
- Contest logging
- Morse code keying

### 🏆 Full Edition
*Complete HAM radio toolkit for serious operators*

**All Applications from Previous Editions Plus:**
- **xnec2c** - Antenna modeling and analysis
- **TLF** - Contest logging software
- **Chirp** - Radio programming tool
- **Gpredict** - Satellite tracking software

**Use Cases:**
- Contest station operation
- Antenna design and modeling
- Satellite communication
- Multi-mode operation
- Emergency communication

## Hardware Support

### x86 Desktop/Laptop
- Live ISO boot capability
- Full hardware detection
- Audio interface support

### Raspberry Pi Family
- **Pi 3/3+** - Basic operation with 1GB RAM
- **Pi 4** - Recommended platform (2-8GB RAM)
- **Pi 400** - Desktop-optimized Pi4 configuration
- **Pi Zero 2W** - Ultralight setup (512MB RAM optimized)
- **Pi 5** - Latest hardware support

**Features:**
- **Automatic SD Card Expansion** - Root filesystem automatically expands to use the full SD card on first boot
- **Default Hostname:** `qrp-pi` (for all Raspberry Pi devices)
- Optimized audio stack per device (PulseAudio on low-memory devices, PipeWire on Pi4+)

## Building Images

### Prerequisites
- Nix package manager installed
- Linux system or access to a Linux builder

### Available Builds

```bash
# x86 ISO Images (Live bootable)
nix build .#swl-x86-iso
nix build .#digimodes-x86-iso
nix build .#cw-x86-iso
nix build .#full-x86-iso

# Raspberry Pi SD Card Images
nix build .#swl-rpi4-sd-aarch64
nix build .#digimodes-rpi4-sd-aarch64
nix build .#cw-rpi400-sd-aarch64
nix build .#full-rpi4-sd-aarch64

# Pi Zero 2W (Memory optimized)
nix build .#swl-rpizero2w-sd-aarch64
```

### Testing Configurations

```bash
# Test in VM (Linux only)
nixos-rebuild build-vm --flake .#swl-x86
nixos-rebuild build-vm --flake .#digimodes-x86

# Validate all configurations
nix flake check
```

### Building from macOS

Use a remote Linux builder:

```bash
nix build .#swl-x86-iso --builders 'ssh://user@linux-machine x86_64-linux'
nix build .#digimodes-rpi4-sd-aarch64 --builders 'ssh://user@linux-machine aarch64-linux'
```

## Default User Account

- **Username:** `qrp`
- **Password:** `qrp`
- **Groups:** `wheel`, `audio`, `dialout`, `gpio` (Pi only)

## Development

### Project Structure

```
modules/          # Edition configurations
├── qrp-radio-base.nix   # Common base configuration
├── swl-edition.nix      # SWL-specific packages
├── digimodes-edition.nix # Digital mode packages
├── cw-edition.nix       # CW/Morse packages
└── full-edition.nix     # Complete package set

hardware/         # Hardware-specific configurations
├── x86-minimal.nix      # x86 desktop/laptop
├── rpi-common.nix       # Common Raspberry Pi config
├── rpi3-minimal.nix     # Pi 3/3+
├── rpi4-minimal.nix     # Pi 4
├── rpi400-minimal.nix   # Pi 400 (desktop)
├── rpizero2w-minimal.nix # Pi Zero 2W (memory optimized)
└── rpi5-minimal.nix     # Pi 5

images/           # Base system configuration
└── base-image.nix       # Core OS and desktop environment

config/           # Configuration files
└── i3-config            # i3 window manager configuration
```

### Contributing

1. Fork the repository
2. Create a feature branch
3. Test your changes with `nix flake check`
4. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Philosophy

QRP Radio OS embraces the QRP (low power) philosophy of amateur radio - doing more with less. Just as QRP operators achieve impressive results with minimal power, this distribution provides maximum functionality with minimal system overhead.
