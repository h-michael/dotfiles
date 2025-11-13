function fgwr -d "Remove git worktrees with fzf selection (supports multiple selection)"
    # Check if in a git repository
    set -l git_root (git rev-parse --show-toplevel 2>/dev/null)
    if test $status -ne 0
        echo "Error: Not in a git repository"
        return 1
    end

    # Get worktree list with status check (exclude main worktree)
    set -l worktree_info

    # Skip first line (main worktree) and process additional worktrees
    for line in (git worktree list | tail -n +2)
        # Parse: /path/to/worktree  commit [branch-name]
        set -l worktree_path (string split -m 1 ' ' $line)[1]
        set -l branch_name (string match -r '\[([^\]]+)\]' $line)[2]

        # Skip if no branch name (detached HEAD, etc.)
        if test -z "$branch_name"
            continue
        end

        # Check if worktree is clean
        if git -C $worktree_path diff-index --quiet HEAD 2>/dev/null; and test -z (git -C $worktree_path status --porcelain 2>/dev/null)
            set -a worktree_info "$worktree_path"(printf '\t')"$branch_name"(printf '\t')"✓"
        else
            set -a worktree_info "$worktree_path"(printf '\t')"$branch_name"(printf '\t')"⚠"
        end
    end

    if test -z "$worktree_info"
        echo "No additional worktrees found"
        return 0
    end

    # Use fzf for multi-selection
    set -l selected (printf "%s\n" $worktree_info | \
        fzf --multi \
            --prompt="Select worktrees to remove: " \
            --delimiter="\t" \
            --with-nth=2,3 \
            --nth=2)

    if test -z "$selected"
        echo "No worktrees selected"
        return 0
    end

    # Count selected worktrees
    set -l count (echo $selected | wc -l | tr -d ' ')

    # Confirm deletion
    echo "Selected worktrees for removal:"
    echo $selected | while read -l line
        set -l worktree_path (echo $line | cut -f1)
        set -l branch_name (echo $line | cut -f2)
        set -l status_icon (echo $line | cut -f3)
        echo "  - $branch_name ($status_icon) - $worktree_path"
    end
    echo ""

    read -l -P "Remove $count worktree(s)? [y/N] " confirm
    if test "$confirm" != y -a "$confirm" != Y
        echo Cancelled
        return 0
    end

    # Remove selected worktrees
    set -l removed 0
    set -l failed 0

    echo $selected | while read -l line
        set -l worktree_path (echo $line | cut -f1)
        set -l branch_name (echo $line | cut -f2)

        echo "Removing worktree: $worktree_path ($branch_name)"

        # Remove worktree
        if git worktree remove $worktree_path
            echo "  ✓ Successfully removed: $worktree_path"
            set removed (math $removed + 1)
        else
            echo "  ✗ Failed to remove: $worktree_path"
            set failed (math $failed + 1)
        end
    end

    echo ""
    echo "Summary:"
    echo "  Removed: $removed"
    if test $failed -gt 0
        echo "  Failed: $failed"
        return 1
    end

    return 0
end
