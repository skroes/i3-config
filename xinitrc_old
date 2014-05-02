#!/bin/sh

#settings
xset -b
#wtf xrdb -merge ~/.i3/xresources

#multiple screen setup
#[ -e ~/.screen_setup ] && source ~/.screen_setup

#background
#[ -e ~/.fehbg ] && source ~/.fehbg

#trackball middle button emulation
#xinput set-prop "Primax Kensington Eagle Trackball" "Evdev Middle Button Emulation" 1

#hide mouse coursor when it isn't used
#unclutter -root -visible &

#dbus instance
eval `dbus-launch --sh-syntax --exit-with-session`

#apps
#start-pulseaudio-x11
#mpd &
#urxvtd &

#keyboard layout
#setxkbmap -layout pl
#setxkbmap -option ctrl:nocaps
#xmodmap ~/.i3/xmodmap
#[ -e ~/.xmodmap_local ] && xmodmap ~/.xmodmap_local

#color temperature adjustment, set for Gdańsk
redshift -l 54.35:18.65 -m randr -t 5500:4500 -g 0.75:0.75:0.75 &

#notification
dunst -config ~/.i3/dunstrc &

#disks automounting
#udiskie &

#other
#[ -e /usr/bin/dropboxd ] && /usr/bin/dropboxd &

# PulseAudio Sound System
# Start the PulseAudio Sound System
start-pulseaudio-x11 &

#creating gpg agent?
GPG_ENVFILE="$HOME/.gnupg/gpg-agent.env"
if [ -x $(which gpg-agent) ]; then
    eval "$(gpg-agent --enable-ssh-support --daemon --write-env-file "$GPG_ENVFILE")"
    export GPG_AGENT_INFO
fi

# GPG Password Agent
/usr/bin/gnome-keyring-daemon --start --components=gpg
# GNOME Keyring: GPG Agent

# Certificate and Key Storage
# GNOME Keyring: PKCS#11 CompCertificate and Key Storageonent
/usr/bin/gnome-keyring-daemon --start --components=pkcs11
#? gnome-keyring-daemon -s &

# Secret Storage Service
# GNOME Keyring: Secret Service
/usr/bin/gnome-keyring-daemon --start --components=secrets

# Spice vdagent
# Agent for Spice guests
/usr/bin/spice-vdagent &

# SSH Key Agent
# GNOME Keyring: SSH Agent
/usr/bin/gnome-keyring-daemon --start --components=ssh

# ClipIt
# Clipboard Manager
clipit &

# Volume Icon
# Show desktop volume control
#volumeicon &

# Evolution Alarm Notify
# Calendar event notifications
/usr/libexec/evolution/3.10/evolution-alarm-notify &

#composition manager
#compton --config ~/.i3/compton.conf &

# DPMS to blank your screen or to suspend/poweroff your monitor. Will suspend your monitor after xxx seconds
xset dpms 1200

# background
feh --bg-scale /home/skroes/.i3/Sochi-Shaun-White.jpg      


gnome-screensaver &

i3

#getting rid of gpg agent
[ -x $(which gpg-agent) ] && kill $(grep GPG_AGENT_INFO "$GPG_ENVFILE" | cut -d: -f 2) 2>/dev/null

true
