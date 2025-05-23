# i3 config for HAM Radio NixOS
set $mod Mod4

# Font
font pango:DejaVu Sans Mono 8

# Start a terminal
bindsym $mod+Return exec alacritty

# Kill focused window
bindsym $mod+Shift+q kill

# Start dmenu
bindsym $mod+d exec dmenu_run

# Change focus
bindsym $mod+j focus left
bindsym $mod+k focus down
bindsym $mod+l focus up
bindsym $mod+semicolon focus right

# Move focused window
bindsym $mod+Shift+j move left
bindsym $mod+Shift+k move down
bindsym $mod+Shift+l move up
bindsym $mod+Shift+semicolon move right

# Split orientation
bindsym $mod+h split h
bindsym $mod+v split v

# Fullscreen
bindsym $mod+f fullscreen toggle

# Restart i3
bindsym $mod+Shift+r restart

# Exit i3
bindsym $mod+Shift+e exec "i3-nagbar -t warning -m 'Exit i3?' -b 'Yes' 'i3-msg exit'"

# System tray
exec --no-startup-id trayer --edge top --align right --widthtype request --padding 6 --SetDockType true --SetPartialStrut true --expand true --monitor 0 --transparent true --alpha 0 --tint 0x000000 --height 22

# Network manager applet
exec --no-startup-id nm-applet

# Volume control
bindsym XF86AudioRaiseVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +10%
bindsym XF86AudioLowerVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -10%
bindsym XF86AudioMute exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle

# Quick launch HAM apps (examples)
bindsym $mod+Shift+f exec fldigi
bindsym $mod+Shift+w exec wsjt-x
bindsym $mod+Shift+g exec gqrx

# Workspaces
bindsym $mod+1 workspace 1
bindsym $mod+2 workspace 2
# ... etc

# Move to workspace
bindsym $mod+Shift+1 move container to workspace 1
bindsym $mod+Shift+2 move container to workspace 2
# ... etc