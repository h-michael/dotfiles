# Format token usage display for Claude Code statusline
# Args:
#   $argv[1] - total tokens
# Returns:
#   Plain text token count with k/M suffixes for large numbers, or empty string if zero

function cc_statusline_tokens
    set -l total_tokens $argv[1]

    # Validate input
    if test -z "$total_tokens"; or not string match -qr '^[0-9]+$' -- "$total_tokens"
        return
    end

    if test $total_tokens -eq 0
        return
    end

    # Format tokens in compact form (k for thousands, M for millions)
    if test $total_tokens -ge 1000000
        set -l tokens_millions (echo "scale=1; $total_tokens / 1000000" | bc 2>/dev/null)
        if test -z "$tokens_millions"
            set tokens_millions (math "$total_tokens / 1000000")
        end
        printf "%.1fM" $tokens_millions
    else if test $total_tokens -ge 1000
        set -l tokens_thousands (math "$total_tokens / 1000")
        printf "%.0fk" $tokens_thousands
    else
        printf "%d" $total_tokens
    end
end
