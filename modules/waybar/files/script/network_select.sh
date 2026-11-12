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

networks=$(nmcli -t -f SSID dev wifi list | grep -v '^--' | sort -u)
selection=$(printf '%s\n' "$networks" | menu "Wi-Fi SSID") || exit 0

[[ -z "$selection" ]] && exit

nmcli device wifi connect "$selection"
