#!/bin/bash

killall waybar
waybar -c ~/.config/waybar/top.jsonc &> /dev/null & disown
waybar -c ~/.config/waybar/bottom.jsonc &> /dev/null & disown
