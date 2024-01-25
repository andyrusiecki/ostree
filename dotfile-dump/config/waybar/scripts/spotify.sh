#!/bin/bash

status="$(playerctl -p spotify status)"
prefix=""

if [ "$status" = "Paused" ]; then
  prefix=""
fi

playerctl -p spotify metadata --format "{\"text\": \"$prefix {{ markup_escape(artist) }} - {{ markup_escape(title) }}\"}"
