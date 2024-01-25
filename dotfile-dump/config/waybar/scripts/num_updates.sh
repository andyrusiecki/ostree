#!/bin/bash

cache_file="$HOME/.cache/pending_updates"
num_updates=$(cat $cache_file | wc -l)

tooltip="Last Checked $(relative-date `stat -c '%Y' $cache_file`)"
alt=""
text=""

if [ $num_updates -gt 0 ]; then
    tooltip+="\n\n$(cat $cache_file | column -t | awk -v ORS='\\n' 1)"
    alt="updates"
    text="$num_updates"
fi

echo "{\"alt\":\"$alt\",\"text\":\"$text\",\"tooltip\":\"$tooltip\"}"
#jq -nc \
#    --arg alt "$alt" \
#    --arg text "$text" \
#    --arg tooltip "$tooltip" \
#    '{alt: $alt, text: $text, tooltip: $tooltip}'

exit

arch=$(checkupdates | wc -l)
aur=$(pacman -Qm | aur vercmp | wc -l)
flatpak=$(flatpak remote-ls --updates | wc -l)

num_updates=$((arch + aur + flatpak))
alt=""
text=""

if [ $num_updates -gt 0 ]; then
    alt="updates"
    text="$num_updates"
fi

echo "{\"alt\":\"$alt\",\"text\":\"$text\"}"
