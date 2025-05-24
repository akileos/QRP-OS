{ config, lib, pkgs, ... }:

{
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
  ];

  # Audio system - essential for HAM radio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;  # For low-latency digital modes
  };
  
  # Explicitly disable PulseAudio when PipeWire is enabled
  hardware.pulseaudio.enable = false;

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

  # Minimal X11 desktop environment for HAM radio GUI apps
  services.xserver = {
    enable = true;
    
    # Use automatic display manager instead of lightdm to reduce dependencies
    displayManager.startx.enable = true;
    
    # Minimal window manager
    windowManager.dwm.enable = true;
    
    # Disable desktop manager to keep it minimal
    desktopManager.xterm.enable = false;
  };

  # NetworkManager with minimal GUI support
  networking.networkmanager.enable = true;
  networking.wireless.enable = false;

  # Default user for radio system
  users.users.qrp = {
    isNormalUser = true;
    extraGroups = [ 
      "wheel" "audio" "dialout" "plugdev" 
      "networkmanager" "video"
    ];
    password = "qrp";
  };

  # Enable SSH for remote access
  services.openssh.enable = true;

  # Essential packages for HAM radio GUI applications
  environment.systemPackages = with pkgs; [
    # Audio tools
    alsa-utils
    pavucontrol
    
    # USB/Serial tools
    minicom
    picocom
    screen
    
    # Network tools
    wirelesstools
    wpa_supplicant
    
    # Hardware detection
    usbutils  # lsusb
    pciutils  # lspci
    
    # Basic utilities
    htop
    vim
    nano
    git
    wget
    curl
    
    # Minimal X11 tools
    xterm
    xorg.xrandr
    
    # Simple application launcher
    dmenu
    
    # Essential for radio work
    socat
    netcat
  ];
  
  # Increase ulimits for SDR applications
  security.pam.loginLimits = [
    { domain = "@audio"; item = "memlock"; type = "hard"; value = "unlimited"; }
    { domain = "@audio"; item = "rtprio"; type = "hard"; value = "99"; }
  ];
}