# Format session cost display for Claude Code statusline
# Args:
#   $argv[1] - total cost in USD
# Returns:
#   Plain text cost string (only if cost > $0.01), or empty string if below threshold

function cc_statusline_cost
    set -l total_cost $argv[1]

    # Validate input
    if test -z "$total_cost"
        return
    end

    # Only show if cost exceeds threshold
    set -l cost_threshold 0.01
    set -l cost_exceeds (echo "$total_cost > $cost_threshold" | bc -l 2>/dev/null || echo 0)
    if test "$cost_exceeds" != 1
        return
    end

    printf "\$%.3f" $total_cost
end

# Calculate and display block timer with progress bar for Claude Code statusline
# Args:
#   $argv[1] - transcript file path
# Returns:
#   Plain text with progress bar and time: "[████████░░░░░░░░] 3.7h" or empty string on error
# Note: Blocks are 5 hours each, starting from the first message timestamp
