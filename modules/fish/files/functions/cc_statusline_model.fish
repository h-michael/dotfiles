# Format model display name for Claude Code statusline
# Args:
#   $argv[1] - model display name (e.g., "Claude 3.5 Sonnet")
# Returns:
#   Plain text shortened model name, or empty string if invalid

function cc_statusline_model
    set -l model_display $argv[1]
    if test -z "$model_display"; or test "$model_display" = null
        return
    end

    # Shorten model name (remove "Claude " prefix and replace spaces with dashes)
    set -l model_short (echo $model_display | sed 's/Claude //' | sed 's/ /-/g')
    echo $model_short
end
