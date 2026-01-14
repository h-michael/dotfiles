function fgc -d "git checkout selected branch"
    set -l default_branch (git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | string replace 'refs/remotes/origin/' '')
    set -l merged_branches (git branch --merged $default_branch 2>/dev/null | string trim | string replace -r '^\* ' '')
    set -l branch (git branch | string trim | string replace -r '^\* ' '' | while read -l b
        if test "$b" = "$default_branch"
            echo $b
        else if contains $b $merged_branches
            echo "$b [merged]"
        else
            echo $b
        end
    end | fzf --reverse --prompt="Select branch: " | string replace ' [merged]' '')

    if test -n "$branch"
        git checkout $branch
    end
end
