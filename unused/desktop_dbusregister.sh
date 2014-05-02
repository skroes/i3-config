#!/bin/bash - 
if [ -n "$DESKTOP_AUTOSTART_ID" ]; then  
echo "Registering with Gnome Session Manager via Dbus and id $DESKTOP_AUTOSTART_ID"  
dbus-send --session --print-reply=string --dest=org.gnome.SessionManager "/org/gnome/SessionManager" org.gnome.SessionManager.RegisterClient "string:i3" "string:$DESKTOP_AUTOSTART_ID"  
else  
echo "DESKTOP_AUTOSTART_ID not set."  
fi  
