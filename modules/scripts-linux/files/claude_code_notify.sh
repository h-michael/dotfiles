#!/bin/bash
# Send Claude Code notification with click action and sound
# Usage: claude_code_notify.sh <title> <message> [sound] [transcript_path] [cwd]

TERMINAL_CLASS="com.mitchellh.ghostty"

TITLE="${1:-Claude Code}"
MESSAGE="${2:-Task completed}"
SOUND="${3:-message.oga}"
TRANSCRIPT_PATH="${4:-}"
CWD="${5:-}"

# Get project name from cwd or transcript
PROJECT_NAME=""
if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
    # Read cwd from last element of jsonl transcript
    PROJECT_DIR=$(jq -rs '.[-1].cwd // empty' "$TRANSCRIPT_PATH" 2>/dev/null)
    if [ -n "$PROJECT_DIR" ] && [ "$PROJECT_DIR" != "null" ]; then
        PROJECT_NAME=$(basename "$PROJECT_DIR")
    fi
elif [ -n "$CWD" ]; then
    # For Notification event, use cwd from argument
    PROJECT_NAME=$(basename "$CWD")
fi

# Add project name to title if available
if [ -n "$PROJECT_NAME" ]; then
    TITLE="$TITLE - $PROJECT_NAME"
fi

# Check if Ghostty is currently active
ACTIVE_CLASS=$(hyprctl activewindow -j 2>/dev/null | jq -r '.class // empty')

# Play notification sound only if terminal is not active
if [ "$ACTIVE_CLASS" != "$TERMINAL_CLASS" ]; then
    pw-play "/usr/share/sounds/freedesktop/stereo/$SOUND" &
fi

ACTION=$(notify-send -a "Claude Code" --action="default=Focus" "$TITLE" "$MESSAGE")

if [ "$ACTION" = "default" ]; then
    hyprctl dispatch focuswindow "class:$TERMINAL_CLASS"
fi