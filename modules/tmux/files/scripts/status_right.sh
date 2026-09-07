#!/usr/bin/env bash
# Produces the whole "online cpu battery" segment of status-right in one
# process. Emitting it from a single #() instead of three keeps the
# per-tick fork count down, which is what matters when many sessions
# refresh their status line at once. Runs behind cached_status.sh, so
# this only executes once per TTL.
set -u

online_status() {
  local _ dest
  if [[ $OSTYPE == darwin* ]]; then
    route -n get default >/dev/null 2>&1
  else
    # Read the kernel routing table directly rather than depending on
    # iproute2 being on PATH. A default route has destination 00000000.
    while read -r _ dest _; do
      [[ $dest == 00000000 ]] && return 0
    done </proc/net/route
    return 1
  fi
}

# CPU utilisation (busy = 100 - idle). Load average was tried first but
# it counts runnable threads, not CPU time, and on macOS regularly reads
# 150%+ while top shows 15% busy.
#
# macOS: `top -l 1 -n 0` returns its CPU line without a sampling delay
# (~0.6s, mostly sys), unlike `iostat -c 2` which blocks for 2s.
# Linux: /proc/stat only exposes cumulative ticks, so keep the previous
# sample next to the status cache and report the delta. The first call
# after boot has nothing to diff against and prints "--".
cpu_usage() {
  local idle prev_file total idle_now prev_total prev_idle
  local -a f
  if [[ $OSTYPE == darwin* ]]; then
    idle=$(top -l 1 -n 0 | awk '/^CPU usage/ { sub("%", "", $7); print $7 }')
    [[ -n $idle ]] || { printf -- '--%%'; return; }
    awk -v i="$idle" 'BEGIN { printf "%3.0f%%", 100 - i }'
  else
    read -r -a f </proc/stat
    # f[1..7] = user nice system idle iowait irq softirq
    idle_now=$((f[4] + f[5]))
    total=$((f[1] + f[2] + f[3] + f[4] + f[5] + f[6] + f[7]))
    prev_file="${TMPDIR:-/tmp}/tmux-status-cache-$UID/cpu_prev"
    if [[ -r $prev_file ]]; then
      read -r prev_total prev_idle <"$prev_file"
    fi
    printf '%s %s\n' "$total" "$idle_now" >|"$prev_file"
    if [[ -z ${prev_total:-} ]] || ((total <= prev_total)); then
      printf -- '--%%'
      return
    fi
    printf '%3d%%' $(((100 * ((total - prev_total) - (idle_now - prev_idle))) / (total - prev_total)))
  fi
}

# Emoji prefix encodes the power state so the bare percentage is not
# mistaken for the CPU figure next to it:
#   ⚡ charging   🔌 on AC, charged or not charging   🔋 on battery
battery_status() {
  local pct state icon line dir
  if [[ $OSTYPE == darwin* ]]; then
    # pmset -g batt second line: " -InternalBattery-0 (id=...)\t100%; charged; 0:00 remaining ..."
    line=$(pmset -g batt | grep -m1 'InternalBattery') || return
    pct=${line#*$'\t'}
    pct=${pct%%;*}
    state=${line#*; }
    state=${state%%;*}
    case $state in
      charging) icon="⚡" ;;
      charged | "AC attached" | finishing*) icon="🔌" ;;
      *) icon="🔋" ;;
    esac
  else
    for dir in /sys/class/power_supply/BAT*; do
      [[ -r $dir/capacity ]] || continue
      read -r pct <"$dir/capacity"
      pct="$pct%"
      read -r state <"$dir/status" 2>/dev/null || state=Unknown
      case $state in
        Charging) icon="⚡" ;;
        Full | "Not charging") icon="🔌" ;;
        *) icon="🔋" ;;
      esac
      break
    done
    [[ -n ${pct:-} ]] || return
  fi
  printf '%s %s' "$icon" "$pct"
}

if online_status; then
  online="✅"
else
  online="⛔"
fi

# 󰍛 is nf-md-memory (U+F035B, Nerd Fonts v3 range); Ghostty falls back to
# PlemolJP Console NF for it when the primary font lacks the glyph.
printf '%s 󰍛%s  %s' "$online" "$(cpu_usage)" "$(battery_status)"
