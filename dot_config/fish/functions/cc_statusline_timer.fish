# Format execution time display for Claude Code statusline
# Args:
#   $argv[1] - start time in nanoseconds
# Returns:
#   Plain text execution time in milliseconds, or empty string if invalid

function cc_statusline_timer
    set -l start_time_ns $argv[1]

    if test -z "$start_time_ns"
        return
    end

    # Get current time in nanoseconds
    set -l end_time_ns (date +%s%N 2>/dev/null)
    if test -z "$end_time_ns"
        # Fallback to gdate if available
        if command -v gdate >/dev/null 2>&1
            set end_time_ns (gdate +%s%N 2>/dev/null)
        else
            # Fallback to seconds
            set end_time_ns (math (date +%s) "*" 1000000000)
        end
    end

    # Calculate elapsed time in milliseconds
    set -l elapsed_ns (math "$end_time_ns - $start_time_ns")
    set -l elapsed_ms (math --scale=0 "$elapsed_ns / 1000000")

    # Only show if execution time > 0ms
    if test $elapsed_ms -le 0
        return
    end

    printf "%dms" $elapsed_ms
end
