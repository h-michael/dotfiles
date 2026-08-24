function fgdb -d "git delete selected branch"
    argparse merged -- $argv
    or return

    set -l default_branch (git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | string replace 'refs/remotes/origin/' '')
    set -l merged_branches (git branch --merged $default_branch 2>/dev/null | string trim | string replace -r '^\* ' '')
    set -l default_sha (git rev-parse $default_branch 2>/dev/null)

    set -l branches (git branch | string trim | string replace -r '^\* ' '' | while read -l b
        if test "$b" = "$default_branch"
            continue
        end

        set -l is_merged (contains $b $merged_branches; and echo yes; or echo no)
        set -l label ''
        if test "$is_merged" = yes
            if test (git rev-parse $b 2>/dev/null) = "$default_sha"
                set label ' '(set_color cyan)'[no unique commits]'(set_color normal)
            else
                set label ' '(set_color yellow)'[merged]'(set_color normal)
            end
        end

        if set -q _flag_merged
            if test "$is_merged" = yes
                echo "$b$label"
            end
        else
            echo "$b$label"
        end
    end | fzf --ansi --multi --prompt="Select branches to delete: " | string replace -ra '\x1b\[[0-9;]*m' '' | string replace -r ' \[(merged|no unique commits)\]$' '')

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
