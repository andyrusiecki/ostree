#!/bin/sh

image="$1"
dir=$(dirname $(realpath $0))
fonts="$(jq -r '.'$1'.fonts.nerd[]' $dir/config.json | tr '\n' ' ')"

tmp_dir=$(mktemp -d)

mkdir -p /usr/share/fonts/nerd

for font in $fonts
do
  curl -L https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$font.zip --output $tmp_dir/$font.zip
  unzip $tmp_dir/$font.zip -d /usr/share/fonts/nerd/$font/
done

rm -rf $tmp_dir
