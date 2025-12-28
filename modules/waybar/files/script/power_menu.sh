#!/usr/bin/env bash

set -euo pipefail

options="🔒 Lock
🔙 Logout
🛌 Sleep
🌙 Hibernate
⏻ Shutdown
🔁 Reboot"

choice=$(printf '%s\n' "$options" | \
    rofi -dmenu -p "Power Menu" \
         -i             \
         -no-custom)

[[ -z ${choice:-} ]] && exit 0

case "$choice" in
  "🔒 Lock")      hyprlock ;;
  "🔙 Logout")    hyprctl dispatch exit ;;
  "🛌 Sleep")     systemctl suspend ;;
  "🌙 Hibernate") systemctl hibernate ;;
  "⏻ Shutdown")   systemctl poweroff ;;
  "🔁 Reboot")    systemctl reboot ;;
esac
