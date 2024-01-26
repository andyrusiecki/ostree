#!/bin/bash

tmp_dir=$(mktemp -d)

git clone --depth=1 https://github.com/hyprwm/contrib $tmp_dir

install -v -D -m 0644 $tmp_dir/grimblast/grimblast.1 --target-directory "/usr/local/man"
install -v -D -m 0755 $tmp_dir/grimblast/grimblast --target-directory "/usr/local/bin"

cp $tmp_dir/grimblast/screenshot.sh /usr/share/olivine/hypr/rofi-screenshot
chmod 755 /usr/share/olivine/hypr/rofi-screenshot

rm -rf $tmp_dir
