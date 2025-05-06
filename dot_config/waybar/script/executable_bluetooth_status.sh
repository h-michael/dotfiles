#!/usr/bin/env bash

set -euo pipefail

status="OFF"
icon="󰂰"
connections="No devices connected"

if bluetoothctl show | grep -q "Powered: yes"; then
  status="ON"
  icon="󰂯"

  if bluetoothctl info | grep -q "Connected: yes"; then
    status="CONNECTED"
    icon="󰂱"
    connections=$(bluetoothctl info | grep "Name" | cut -d' ' -f2-)
  fi
fi

echo "{\"text\": \"$icon $status\", \"tooltip\": \"$connections\"}"
