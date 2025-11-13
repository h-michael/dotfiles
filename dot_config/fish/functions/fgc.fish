function fgc -d "git checkout selected branch"
    set -l branch (git branch | fzf --reverse --prompt="Select branch: " | string trim | string replace -r '^\* ' '')
    if test -n "$branch"
        git checkout $branch
    end
end
