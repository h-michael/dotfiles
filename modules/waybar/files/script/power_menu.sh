#!/usr/bin/env bash

set -euo pipefail

options="🔒 Lock
🔙 Logout
🛌 Sleep
🌙 Hibernate
⏻ Shutdown
🔁 Reboot"

# Detect launcher: fuzzel for niri, rofi for Hyprland
if [ -n "${NIRI_SOCKET:-}" ]; then
    choice=$(printf '%s\n' "$options" | \
        fuzzel --dmenu --prompt "Power Menu> ")
else
    choice=$(printf '%s\n' "$options" | \
        rofi -dmenu -p "Power Menu" \
             -i             \
             -no-custom)
fi

[[ -z ${choice:-} ]] && exit 0

# Compositor-specific lock/logout commands
if [ -n "${NIRI_SOCKET:-}" ]; then
    case "$choice" in
      "🔒 Lock")      swaylock -f ;;
      "🔙 Logout")    niri msg action quit ;;
      "🛌 Sleep")     systemctl suspend ;;
      "🌙 Hibernate") systemctl hibernate ;;
      "⏻ Shutdown")   systemctl poweroff ;;
      "🔁 Reboot")    systemctl reboot ;;
    esac
else
    case "$choice" in
      "🔒 Lock")      hyprlock ;;
      "🔙 Logout")    hyprctl dispatch exit ;;
      "🛌 Sleep")     systemctl suspend ;;
      "🌙 Hibernate") systemctl hibernate ;;
      "⏻ Shutdown")   systemctl poweroff ;;
      "🔁 Reboot")    systemctl reboot ;;
    esac
fi
