function fgdb -d "git delete selected branch"
    set -l default_branch (git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | string replace 'refs/remotes/origin/' '')
    set -l merged_branches (git branch --merged $default_branch 2>/dev/null | string trim | string replace -r '^\* ' '')
    set -l branches (git branch | string trim | string replace -r '^\* ' '' | while read -l b
        if test "$b" = "$default_branch"
            continue
        end
        if contains $b $merged_branches
            echo "$b [merged]"
        else
            echo $b
        end
    end | fzf --multi --prompt="Select branches to delete: " | string replace ' [merged]' '')

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
