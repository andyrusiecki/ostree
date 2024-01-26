#!/bin/bash
monitor_count="$(hyprctl monitors -j | jq '. | length')"

if [ "$monitor_count" != "2" ]; then
    echo "Found ${monitor_count} monitors instead of 2"
    exit
fi

function set_workspaces {
    local min=$1
    local max=$2
    local monitor_id="$3"
    local monitor_name="$4"

    for ((workspace = $min; workspace <= $max; workspace++)); do
        is_default=false
        if [ "$workspace" = "$min" ]; then
            is_default=true
        fi

        echo "Workspace $workspace (default: $is_default) on $monitor_id: $monitor_name"

        hyprctl dispatch moveworkspacetomonitor $workspace "$monitor_name" &> /dev/null
        hyprctl keyword workspace $workspace, monitor:$monitor_name, default:$is_default &> /dev/null
    done
}

hyprctl monitors -j | jq -r '.[] | "\(.id)|\(.name)|\(.description)"' | while IFS=\| read -r monitor_id monitor_name monitor_desc;
do
    if [ "$monitor_name" != "eDP-1" ]; then
        set_workspaces 1 5 "$monitor_id" "$monitor_name"
    else
        if [ "$monitor_count" = "1" ]; then
            set_workspaces 1 10 "$monitor_id" "$monitor_name"
        else
            set_workspaces 6 10 "$monitor_id" "$monitor_name"
        fi
    fi
done
