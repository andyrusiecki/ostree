#!/bin/sh
image="$1"
dir=$(dirname $(realpath $0))
pkgs="$(jq -r '.'$1'.packages.remove[]' $dir/config.json | tr '\n' ' ')"

rpm-ostree override remove $pkgs
