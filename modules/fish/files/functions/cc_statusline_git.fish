# Get git branch and status indicators for Claude Code statusline
# Args:
#   $argv[1] - current directory path
# Returns:
#   Plain text git info in format "on BRANCH [STATUS]" or "on BRANCH", or empty string if not in git repo

function cc_statusline_git
    set -l current_dir $argv[1]
    if test -z "$current_dir"
        return
    end

    # Check if in git repository
    if not test -d "$current_dir/.git"
        if not git -C "$current_dir" rev-parse --git-dir >/dev/null 2>&1
            return
        end
    end

    # Get current branch
    set -l branch (git -C "$current_dir" branch --show-current 2>/dev/null)
    if test -z "$branch"
        set branch detached
    end

    # Get git status indicators
    set -l git_status ""
    set -l status_output (git -C "$current_dir" status --porcelain 2>/dev/null)

    if test -n "$status_output"
        # Count files with any changes in the index (staged area)
        # First character indicates index status: M=modified, A=added, D=deleted, R=renamed, etc.
        set -l staged (printf "%s\n" $status_output | grep -E "^[MADRCU]" 2>/dev/null | wc -l | string trim)

        # Count files with unstaged modifications in working tree
        # Second character indicates working tree status: M=modified, D=deleted
        set -l modified (printf "%s\n" $status_output | grep -E "^.[MD]" 2>/dev/null | wc -l | string trim)

        # Count untracked files
        set -l untracked (printf "%s\n" $status_output | grep "^??" 2>/dev/null | wc -l | string trim)

        set -l git_indicators
        test $staged -gt 0; and set -a git_indicators "+"
        test $modified -gt 0; and set -a git_indicators "!"
        test $untracked -gt 0; and set -a git_indicators "?"

        if test (count $git_indicators) -gt 0
            set git_status (printf " [%s]" (string join "" $git_indicators))
        end
    end

    printf "on %s%s" $branch $git_status
end
