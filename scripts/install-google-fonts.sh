#!/bin/sh

image="$1"
dir=$(dirname $(realpath $0))
fonts="$(jq -r '.'$1'.fonts.google[]' $dir/config.json | tr '\n' ' ')"

tmp_dir=$(mktemp -d)

mkdir -p /usr/share/fonts/google

for font in $fonts
do
  curl -L https://fonts.google.com/download?family=${font// /%20}.zip --output $tmp_dir/$font.zip
  unzip $tmp_dir/$font.zip -d /usr/share/fonts/google/$font/
done

rm -rf $tmp_dir
