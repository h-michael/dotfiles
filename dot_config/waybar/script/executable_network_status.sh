#!/usr/bin/env bash

set -euo pipefail

ssid=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d':' -f2-)
strength=$(nmcli -t -f active,signal dev wifi | grep '^yes' | cut -d':' -f2)

icon="󰤯"  # disconnected by default

if [[ -n "$ssid" ]]; then
  if (( strength >= 80 )); then
    icon="󰤨"
  elif (( strength >= 60 )); then
    icon="󰤥"
  elif (( strength >= 40 )); then
    icon="󰤢"
  elif (( strength >= 20 )); then
    icon="󰤟"
  else
    icon="󰤯"
  fi
  text="$icon"
  tooltip="$ssid ($strength%)"
else
  text="$icon"
  tooltip="Disconnected"
fi

echo "{\"text\": \"$text\", \"tooltip\": \"$tooltip\"}"
