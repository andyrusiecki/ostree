#!/bin/bash

mkdir -p ~/.cache/olivine &>/dev/null

colorSchemeCache="~/.cache/olivine/color-scheme"
wallpaperCache="~/.cache/olivine/wallpaper"

function currentColorScheme() {
  echo "Name: $(yq '.name' $colorSchemeCache)"
  echo "System: $(yq '.system' $colorSchemeCache)"
  echo "Variant: $(yq '.variant' $colorSchemeCache)"
  echo ""
  palette
}

function palette() {
  for ((i=0;i<=15;i++)); do
    if [ $i -eq 8 ]; then
      echo ""
    fi
    if [ $i -lt 8 ]; then
      echo -en "\e[4${i}m    \e[0m"
    else
      echo -en "\e[48;5;${i}m    \e[0m"
    fi
  done

  echo ""
}

case $1 in
  get-scheme)
    currentColorScheme
    ;;
  set-scheme)
    newColorScheme="/usr/share/olivine/themes/$2.yaml"

    if ! [ -e $newColorScheme ]; then
      echo "Color Scheme $2 does not exist!"
      exit 1
    fi

    ln -fs $newColorScheme $colorSchemeCache

    currentColorScheme

    echo "Color Scheme '$2' Successfully Applied!"
    ;;
  schemes)
    echo "Available Color Schemes:"
    ls /usr/share/olivine/themes | awk -F . '{ print $1 }'
    ;;
  get-wallpaper)
    echo "Current Wallpaper: $(realpath $wallpaperCache)"
    if command -v catimg; then
      catimg $(realpath $wallpaperCache)
    fi
    ;;
  set-wallpaper)
    newWallpaper="$(realpath $2)"

    if ! [ -e $newWallpaper ]; then
      echo "Wallpaper at path $2 does not exist!"
      exit 1
    fi

    ln -fs $newWallpaper $wallpaperCache

    # reload wallpaper
    pid=$(ps axf | grep swaybg | grep -v grep | awk '{print $1}')
    swaybg -m fill -i $wallpaperCache &
    disown
    $(
      sleep 1
      kill $pid
    ) &
    disown

    echo "New Wallpaper: $(realpath $wallpaperCache)"
    if command -v catimg; then
      catimg $(realpath $wallpaperCache)
    fi
    ;;
  *)
    echo "TODO: color subcommand usage"
    ;;
esac
