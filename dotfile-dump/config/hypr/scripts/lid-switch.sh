#!/bin/bash

if grep open /proc/acpi/button/lid/LID0/state; then 
	hyprctl keyword monitor "eDP-1, 2256x1504, auto, 1.25"
elif [[ `hyprctl monitors | grep "Monitor" | wc -l` != 1 ]]; then
	hyprctl keyword monitor "eDP-1, disable"
else
	swaylock
	systemctl suspend
fi
