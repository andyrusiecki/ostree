#!/bin/bash

now="$(date '+%s')"
format="+%I:%M %p"

timezones=(
	"America/New_York"
	"Europe/Dublin"
	"Etc/UTC"
)

tz_labels=(
	"New York"
	"Ireland"
	"UTC"
)

tooltip=""

for i in "${!timezones[@]}"; do
	tz="${timezones[$i]}"
	label="${tz_labels[$i]}"

	if [[ "$label" == "" ]]; then
		label="$tz"
	fi
	
	printf -v line "%-10s %-10s\\\n" "$label" "$(TZ="$tz" date "$format")"
	tooltip+=$line
done

echo "{\"text\":\"$(date --date="@$now" "$format")\",\"tooltip\":\"$tooltip\"}"
