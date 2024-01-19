#!/bin/sh
image="$1"
dir=$(dirname $(realpath $0))
pkgs="$(jq -r '.'$1'.packages.add[]' $dir/config.json | tr '\n' ' ')"

rpm-ostree install $pkgs
