#!/bin/bash

echo "=== Arch + AUR ==="
paru -Syu --noupgrademenu --removemake

echo ""
echo "=== flatpak ==="
flatpak update

# check for updates after
echo ""
echo "Updating list of pending updates..."
~/.config/hypr/scripts/check-pending-updates.sh

# close
echo ""
read -p "Press Enter to Close"
