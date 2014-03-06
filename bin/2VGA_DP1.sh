#!/bin/sh

#1600x1200
#xrandr --output LVDS-1 --mode 1600x900 --pos 0x0 --rotate normal --output DP-3 --off --output DP-2 --off --output DP-1 --off --output VGA-1 --mode 1600x1200 --pos 1600x0 --rotate normal

#1280x1024
#xrandr --output LVDS-1 --mode 1600x900 --pos 0x0 --rotate normal --output DP-3 --off --output DP-2 --off --output DP-1 --off --output VGA-1 --mode 1280x1024 --pos 0x0 --rotate normal

#xrandr --output LVDS-1 --mode 1600x900 --pos 0x0 --rotate normal --output DP-3 --off --output DP-2 --off --output DP-1 --off --output VGA-1 --auto --pos 1600x0 --rotate normal

# 1280x800
xrandr --output LVDS-1 --mode 1600x900 --pos 0x0 --rotate normal --output DP-3 --off --output DP-2 --off --output DP-1 --off --output VGA-1 --mode 1280x800 --pos 0x0 --rotate normal
#auto --pos 1600x0 --rotate normal --output VGA-1 --off

/opt/home/skroes/.i3/bin/i3_setbackground
