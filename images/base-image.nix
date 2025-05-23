{ config, lib, pkgs, ... }:

{
  # Don't import installation-cd-minimal.nix when using nixos-generators
  # as it conflicts with the generator's own configurations

  # Set state version
  system.stateVersion = "24.11";

  # Kernel modules for HAM radio hardware
  boot.kernelModules = [ 
    # USB audio support
    "snd-usb-audio" 
    "snd-usbmidi-lib"
    # FTDI USB-serial converters
    "ftdi_sio" 
    "cp210x"
    "pl2303"
    # USB WiFi dongles
    "rtl8192cu" 
    "rt2800usb" 
    "ath9k_htc"
    # RTL-SDR dongles
    "dvb_usb_rtl28xxu"
  ];

  # Firmware for USB WiFi dongles
  hardware.enableRedistributableFirmware = true;
  hardware.firmware = with pkgs; [
    linux-firmware
    rtl8761b-firmware  # Common Bluetooth/WiFi combo chips
  ];

  # Audio system - essential for HAM radio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;  # For low-latency digital modes
  };
  
  # Explicitly disable PulseAudio when PipeWire is enabled
  services.pulseaudio.enable = false;

  # USB device permissions and rules
  services.udev.extraRules = ''
    # USB Audio devices - allow audio group access
    SUBSYSTEM=="sound", GROUP="audio", MODE="0664"
    SUBSYSTEM=="snd", GROUP="audio", MODE="0664"
    
    # FTDI USB-serial devices
    SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", GROUP="dialout", MODE="0664"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6015", GROUP="dialout", MODE="0664"
    
    # CP210x USB-serial devices (common in HAM gear)
    SUBSYSTEM=="tty", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", GROUP="dialout", MODE="0664"
    
    # Prolific USB-serial devices
    SUBSYSTEM=="tty", ATTRS{idVendor}=="067b", ATTRS{idProduct}=="2303", GROUP="dialout", MODE="0664"
    
    # RTL-SDR dongles
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2838", GROUP="plugdev", MODE="0664"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2832", GROUP="plugdev", MODE="0664"
    
    # HackRF
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="6089", GROUP="plugdev", MODE="0664"
    
    # AirSpy
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="60a1", GROUP="plugdev", MODE="0664"
  '';

  # Essential groups for hardware access
  users.groups = {
    dialout = {};
    audio = {};
    plugdev = {};
  };

  # Minimal desktop environment with WiFi GUI
  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    windowManager.i3.enable = true;
  };

  # NetworkManager with GUI support
  networking.networkmanager.enable = true;
  networking.wireless.enable = false;
  networking.networkmanager.wifi.backend = "wpa_supplicant";

  # Enable NetworkManager applet in system tray
  programs.nm-applet.enable = true;


  # Default user for live system
  users.users.qrp = {
    isNormalUser = true;
    extraGroups = [ 
      "wheel" "audio" "dialout" "plugdev" "gpio" 
      "networkmanager" "video"  # video for some SDR apps
    ];
    password = "qrp";
  };

  # Enable SSH for remote access
  services.openssh.enable = true;
  
  # Copy i3 config for better UX
  environment.etc."skel/.config/i3/config".text = builtins.readFile ../config/i3-config;
  
  # Ensure config directory exists and copy i3 config to user
  system.activationScripts.i3config = ''
    mkdir -p /home/qrp/.config/i3
    cp /etc/skel/.config/i3/config /home/qrp/.config/i3/config
    chown -R qrp:users /home/qrp/.config || true
  '';

  # Essential packages for hardware troubleshooting
  environment.systemPackages = with pkgs; [
    # Audio tools
    alsa-utils
    pavucontrol
    pulseaudio  # For pactl, pacmd commands
    
    # USB/Serial tools
    minicom
    picocom
    screen
    
    # Network tools
    wirelesstools
    wpa_supplicant
    wpa_supplicant_gui 
    networkmanagerapplet

    
    # Hardware detection
    usbutils  # lsusb
    pciutils  # lspci
    
    # Basic utilities
    htop
    vim
    nano
    git
    # X11 essentials for GUI apps
    xorg.xrandr
    xorg.xwininfo
    dmenu  # For i3 app launcher
    
    # System tray for nm-applet
    trayer
    
    # Optional: Lightweight file manager
    pcmanfm
    
    # Terminal emulator
    alacritty
  ];
  
  # Increase ulimits for SDR applications
  security.pam.loginLimits = [
    { domain = "@audio"; item = "memlock"; type = "hard"; value = "unlimited"; }
    { domain = "@audio"; item = "rtprio"; type = "hard"; value = "99"; }
  ];
}