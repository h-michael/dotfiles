#!/usr/bin/env bash

set -euo pipefail

networks=$(nmcli -t -f SSID dev wifi list | grep -v '^--' | sort -u)
selection=$(echo "$networks" | wofi --show dmenu --prompt "Wi-Fi SSID")

[[ -z "$selection" ]] && exit

nmcli device wifi connect "$selection"
