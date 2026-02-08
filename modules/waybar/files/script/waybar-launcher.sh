#!/usr/bin/env bash

set -euo pipefail

STYLE="$HOME/.config/waybar/style.css"

if [ -n "${NIRI_SOCKET:-}" ]; then
    CONFIG="$HOME/.config/waybar/config-niri.jsonc"
else
    CONFIG="$HOME/.config/waybar/config.jsonc"
fi

exec waybar -c "$CONFIG" -s "$STYLE"
