# Format code changes indicator for Claude Code statusline
# Args:
#   $argv[1] - lines added
#   $argv[2] - lines removed
# Returns:
#   Plain text changes in format "+N/-M", or empty string if no changes

function cc_statusline_code_changes
    set -l lines_added $argv[1]
    set -l lines_removed $argv[2]

    # Validate inputs
    if test -z "$lines_added"; or not string match -qr '^[0-9]+$' -- "$lines_added"
        set lines_added 0
    end
    if test -z "$lines_removed"; or not string match -qr '^[0-9]+$' -- "$lines_removed"
        set lines_removed 0
    end

    # Only show if there are changes
    if test $lines_added -eq 0; and test $lines_removed -eq 0
        return
    end

    printf "+%d/-%d" $lines_added $lines_removed
end
