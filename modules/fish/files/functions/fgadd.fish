function fgadd -d "git add selected files"
    set -l files (git status -s | grep -e '^ M ' | sed -e 's/^ M //' | fzf --multi --prompt="Select files to add: ")
    if test -n "$files"
        printf "%s\n" $files | xargs git add
        and git status -s
    end
end
