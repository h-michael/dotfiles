#!/usr/bin/env bash
# Show Hyprland keybinds with descriptions in rofi

hyprctl binds -j | jq -r '
  # Modifier bit flags
  def modmask_to_string:
    . as $mask |
    [
      (if ($mask / 64 | floor) % 2 == 1 then "Super" else empty end),
      (if ($mask / 8 | floor) % 2 == 1 then "Alt" else empty end),
      (if ($mask / 4 | floor) % 2 == 1 then "Ctrl" else empty end),
      (if ($mask / 1 | floor) % 2 == 1 then "Shift" else empty end)
    ] | join("+");

  .[] |
  select(.description | length > 0) |
  (.modmask | modmask_to_string) as $mod |
  (if $mod == "" then .key else $mod + " + " + .key end) + "  →  " + .description
' | sort | rofi -dmenu -i -p "Keybinds" -theme-str 'window {width: 600px;}'
