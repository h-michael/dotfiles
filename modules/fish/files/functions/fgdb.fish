function fgdb -d "git delete selected branch"
    argparse merged -- $argv
    or return

    set -l default_branch (git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | string replace 'refs/remotes/origin/' '')
    set -l merged_branches (git branch --merged $default_branch 2>/dev/null | string trim | string replace -r '^\* ' '')

    set -l branches (git branch | string trim | string replace -r '^\* ' '' | while read -l b
        if test "$b" = "$default_branch"
            continue
        end

        set -l is_merged (contains $b $merged_branches; and echo yes; or echo no)

        if set -q _flag_merged
            if test "$is_merged" = yes
                echo "$b [merged]"
            end
        else
            if test "$is_merged" = yes
                echo "$b [merged]"
            else
                echo $b
            end
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
