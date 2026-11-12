#!/usr/bin/env bash

set -euo pipefail

# Same launcher choice as power_menu.sh: fuzzel on niri, rofi on Hyprland
menu() {
    if [ -n "${NIRI_SOCKET:-}" ]; then
        fuzzel --dmenu --prompt "$1> "
    else
        rofi -dmenu -p "$1" -i -no-custom
    fi
}

# "Device <MAC> <name...>"; names may contain spaces
devices=$(bluetoothctl devices | cut -d' ' -f3-)
selection=$(printf '%s\n' "$devices" | menu "Connect to") || exit 0

[[ -z "$selection" ]] && exit

# Get MAC by exact name
mac=$(bluetoothctl devices | awk -v name="$selection" '{
    mac = $2
    sub(/^Device [^ ]+ /, "")
    if ($0 == name) { print mac; exit }
}')
bluetoothctl connect "$mac"
