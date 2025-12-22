function fgdb -d "git delete selected branch"
    # Get list of merged branches
    set -l merged_branches (git branch --merged | string trim)

    # Format branch list with merge status
    set -l branch_list (git branch | while read -l line
        set -l branch (echo $line | string trim | string replace -r '^\* ' '')
        if contains $branch $merged_branches
            echo "$branch [merged]"
        else
            echo "$branch"
        end
    end)

    # Select branches with fzf
    set -l selected (printf "%s\n" $branch_list | fzf --multi --prompt="Select branches to delete: " --ansi)
    if test -z "$selected"
        return 0
    end

    # Extract branch names (remove [merged] marker)
    set -l branches (printf "%s\n" $selected | string replace -r ' \[merged\]$' '')

    echo "Selected branches for deletion:"
    printf "  - %s\n" $branches
    echo ""
    read -l -P "Delete these branches with -D (force)? [y/N] " confirm
    if test "$confirm" = y -o "$confirm" = Y
        printf "%s\n" $branches | xargs git branch -D
    else
        echo Cancelled
    end
end
