#!/usr/bin/env bash

set -euo pipefail

devices=$(bluetoothctl devices | cut -d' ' -f2- | sed 's/^.* //')
selection=$(echo "$devices" | wofi --show dmenu --prompt "Connect to")

[[ -z "$selection" ]] && exit

# Get MAC by name
mac=$(bluetoothctl devices | grep "$selection" | awk '{print $2}')
bluetoothctl connect "$mac"
