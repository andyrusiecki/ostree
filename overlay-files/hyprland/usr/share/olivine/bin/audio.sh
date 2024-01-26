#!/bin/bash

function output_notify() {
  local is_mute=$(pamixer --get-mute)
  local value="$(pamixer --get-volume)"
  local msg="$value%"

  if [ $is_mute == "true" ]; then
    value="0"
    msg="muted"
  fi

  notify-send -e -h string:x-canonical-private-synchronous:volume \
    -h "int:value:$value" -t 2000 "Volume: ${msg}"
}

function input_notify() {
  local is_mute=$(pamixer --default-source --get-mute)
  local value="$(pamixer --default-source --get-volume)"
  local msg="$value%"

  if [ $is_mute == "true" ]; then
    value="0"
    msg="muted"
  fi

  notify-send -e -h string:x-canonical-private-synchronous:microphone \
    -h "int:value:$value" -t 2000 "Microphone: ${msg}"
}

case $1 in
  output)
    case $2 in
      get)
        echo "$(pamixer --get-volume)"
        ;;

      set)
        pamixer --set-volume $3
        output_notify
        ;;

      increase)
        pamixer --increase $3
        output_notify
        ;;

      decrease)
        pamixer --decrease $3
        output_notify
        ;;

      mute)
        pamixer --mute
        output_notify
        ;;

      unmute)
        pamixer --unmute
        output_notify
        ;;

      toggle-mute)
        pamixer --toggle-mute
        output_notify
        ;;
      *)
        echo "TODO: audio output usage"
        ;;
    esac
    ;;

  input)
    case $2 in
      get)
        echo "$(pamixer --default-source --get-volume)"
        ;;

      set)
        pamixer --default-source --set-volume $3
        input_notify
        ;;

      increase)
        pamixer --default-source --increase $3
        input_notify
        ;;

      decrease)
        pamixer --default-source --decrease $3
        input_notify
        ;;

      mute)
        pamixer --default-source --mute
        input_notify
        ;;

      unmute)
        pamixer --default-source --unmute
        input_notify
        ;;

      toggle-mute)
        pamixer --default-source --toggle-mute
        input_notify
        ;;

      *)
        echo "TODO: audio input usage"
        ;;
    esac
    ;;

  *)
    echo "TODO: audio usage"
    ;;
esac
