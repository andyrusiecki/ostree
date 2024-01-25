#!/bin/bash

paused=$(swaync-client -I)
waiting=$(swaync-client -In)

if [ $paused == "true" ]; then
    alt="paused"

    if [ $waiting != 0 ]; then
        text=$waiting
    fi
fi

echo "{\"alt\":\"$alt\",\"text\":\"$text\"}"
