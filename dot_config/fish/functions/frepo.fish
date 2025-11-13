function frepo -d "cd to selected git repository"
    set -l dir (ghq list | fzf +m --prompt="Select repository: ")
    if test -n "$dir"
        cd (ghq root)/$dir
    end
end
