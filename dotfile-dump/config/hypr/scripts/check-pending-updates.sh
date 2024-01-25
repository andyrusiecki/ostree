#!/bin/bash

tmp_file=$(mktemp)

checkupdates >> $tmp_file
paru -Qm | aur vercmp >> $tmp_file

cache_file="$HOME/.cache/pending_updates"

mv $tmp_file $cache_file

echo "Cached list of $(cat $cache_file | wc -l) pending updates to $cache_file"
