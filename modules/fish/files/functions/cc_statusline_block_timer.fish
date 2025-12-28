function cc_statusline_block_timer
    set -l transcript_path $argv[1]

    if test -z "$transcript_path"; or not test -f "$transcript_path"
        return
    end

    # Find the first message timestamp (user or assistant) using single jq pass
    # Transcript format: {"type": "user|assistant", "timestamp": "2025-11-11T12:00:00.000Z", ...}
    set -l first_timestamp (jq -r 'select(.type == "user" or .type == "assistant") | .timestamp' "$transcript_path" 2>/dev/null | head -1)

    if test -z "$first_timestamp"
        return
    end

    # Get current time in epoch seconds
    set -l now_epoch (date +%s)

    # Convert ISO 8601 timestamp to epoch seconds
    # macOS date command format: date -j -f "%Y-%m-%dT%H:%M:%S" "2025-11-11T12:00:00" "+%s"
    # Strip milliseconds and timezone from timestamp (e.g., "2025-11-11T12:00:00.000Z" -> "2025-11-11T12:00:00")
    set -l clean_timestamp (echo $first_timestamp | string replace -r '\.\d+Z?$' '')

    # Convert to epoch - try macOS date first, then GNU date
    set -l first_epoch
    if test (uname) = Darwin
        set first_epoch (date -j -f "%Y-%m-%dT%H:%M:%S" "$clean_timestamp" "+%s" 2>/dev/null)
    else
        set first_epoch (date -d "$clean_timestamp" "+%s" 2>/dev/null)
    end

    if test -z "$first_epoch"; or test "$first_epoch" = ""
        return
    end

    # Calculate total elapsed time from first message
    set -l total_elapsed_seconds (math "$now_epoch - $first_epoch")

    if test $total_elapsed_seconds -lt 0
        return
    end

    # Calculate which 5-hour block we're in (0-indexed)
    set -l block_duration_seconds (math "5 * 3600") # 5 hours in seconds
    set -l current_block (math --scale=0 "$total_elapsed_seconds / $block_duration_seconds")

    # Calculate elapsed time within current block
    set -l block_start_seconds (math "$current_block * $block_duration_seconds")
    set -l elapsed_in_block_seconds (math "$total_elapsed_seconds - $block_start_seconds")

    # Convert to hours (with decimals)
    set -l elapsed_hours (echo "scale=1; $elapsed_in_block_seconds / 3600" | bc 2>/dev/null)

    # Fallback to integer math if bc fails
    if test -z "$elapsed_hours"; or test "$elapsed_hours" = ""
        set elapsed_hours (math --scale=1 "$elapsed_in_block_seconds / 3600")
    end

    # Calculate progress bar (16 characters)
    set -l progress_bars 16
    set -l filled_bars (echo "scale=0; ($elapsed_hours * $progress_bars) / 5" | bc 2>/dev/null)

    # Fallback to integer math if bc fails
    if test -z "$filled_bars"; or test "$filled_bars" = ""
        set filled_bars (math --scale=0 "($elapsed_hours * $progress_bars) / 5")
    end

    # Clamp to 0-16 range
    if test $filled_bars -lt 0
        set filled_bars 0
    else if test $filled_bars -gt $progress_bars
        set filled_bars $progress_bars
    end

    set -l empty_bars (math "$progress_bars - $filled_bars")

    # Build progress bar string
    set -l bar_filled (string repeat -n $filled_bars "█")
    set -l bar_empty (string repeat -n $empty_bars "░")
    set -l progress_bar "[$bar_filled$bar_empty]"

    # Output format: "[████████░░░░░░░░] 3.7h"
    printf "%s %.1fh" "$progress_bar" $elapsed_hours
end
