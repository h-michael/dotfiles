# Format output style display for Claude Code statusline
# Args:
#   $argv[1] - output style name (e.g., "default", "Explanatory")
# Returns:
#   Plain text output style name, or empty string if invalid

function cc_statusline_output_style
    set -l output_style $argv[1]
    if test -z "$output_style"; or test "$output_style" = null
        return
    end

    echo $output_style
end
