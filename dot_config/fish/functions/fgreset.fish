function fgreset -d "git reset selected files"
    set -l files (git status -s | grep -e '^M ' | sed -e 's/^M //' | fzf --multi --prompt="Select files to reset: ")
    if test -n "$files"
        printf "%s\n" $files | xargs git reset
        and git status -s
    end
end
