function fgdb -d "git delete selected branch"
    set -l branches (git branch | fzf --multi --prompt="Select branches to delete: " | string trim | string replace -r '^\* ' '')
    if test -z "$branches"
        return 0
    end

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
