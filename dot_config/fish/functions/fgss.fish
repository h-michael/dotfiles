function fgss -d "git stash show selected stash"
    set -l stash (git stash list | \
        fzf --reverse \
            --prompt="Select stash: " \
            --preview="echo {} | cut -d: -f1 | xargs git stash show -p --color=always | bat --color=always --style=numbers" | \
        cut -d: -f1)

    if test -n "$stash"
        git stash show -p $stash
    end
end
