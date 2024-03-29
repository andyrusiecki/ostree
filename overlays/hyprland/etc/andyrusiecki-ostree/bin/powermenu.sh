#!/bin/bash

option=$(echo -e "lock\nsleep\nrestart\nshutdown" | wofi --dmenu)

case $option in
	lock)
		exec swaylock
		;;
	sleep)
		exec systemctl suspend
		;;
	restart)
		exec systemctl reboot
		;;
	shutdown)
		exec systemctl poweroff
		;;
esac

