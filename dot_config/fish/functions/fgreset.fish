function fgreset -d "git reset selected files"
    git status -s | grep -e '^M ' | sed -e 's/^M //' | fzf --multi | xargs git reset; and git status -s
end
