#!/bin/bash

tmp_dir=$(mktemp -d)

git clone --depth=1 https://github.com/tinted-theming/schemes $tmp_dir

mkdir -p /usr/share/olivine/themes

cp $tmp_dir/base16/*.yaml /usr/share/olivine/themes/

rm -rf $tmp_dir
