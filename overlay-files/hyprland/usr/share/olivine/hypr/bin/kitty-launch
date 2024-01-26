#!/bin/bash

pid=$(hyprctl activewindow -j | jq -r '.pid')

if [ ! -e /tmp/pwd-$pid ]; then
	hyprctl dispatch exec kitty
	exit
fi

hyprctl dispatch exec kitty -- -d $(cat /tmp/pwd-$pid)
