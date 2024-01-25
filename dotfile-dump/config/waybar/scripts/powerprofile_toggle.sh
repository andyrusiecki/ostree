#!/bin/sh

profile="$(powerprofilesctl get)"

if [ "$profile" = "balanced" ]; then
	powerprofilesctl set power-saver
else
	powerprofilesctl set balanced
fi

