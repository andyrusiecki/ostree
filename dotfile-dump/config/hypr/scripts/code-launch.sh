#!/bin/bash

options=$(find ~/src -mindepth 3 -maxdepth 3 -type d | sed -e 's/^\/home\/andy\/src\///g')

selected=$(echo -e "$options" | wofi --dmenu)

if [ "$selected" != "" ]; then
	/usr/bin/code /home/andy/src/$selected
fi

