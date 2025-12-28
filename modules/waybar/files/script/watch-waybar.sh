#!/usr/bin/env bash

set -euo pipefail

watchexec -e css,jsonc,sh -w ~/.config/waybar -- \
  'pkill waybar && waybar -c ~/.config/waybar/config.jsonc &'
