#!/bin/bash

function notify() {
  local value=$(light)
  value=${value%%.*}

  notify-send -e -h string:x-canonical-private-synchronous:brightness \
    -h "int:value:$value" -t 2000 "Brightness: ${value}%"
}

case $1 in
  get)
    echo "$(light -G)"
    ;;

  set)
    light -S $2
    notify
    ;;

  increase)
    light -A $2
    notify
    ;;

  decrease)
    light -U $2
    notify
    ;;

  *)
    echo "TODO: brightness usage"
    ;;
esac
