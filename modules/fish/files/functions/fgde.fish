function fgde -d "Select files with git diff (staged, unstaged, or untracked) and open them in nvim"
    set -l root (git rev-parse --show-toplevel)
    if test -z "$root"
        return 1
    end

    pushd $root

    set -l preview_cmd 'set -l s (echo {} | cut -c1-2); set -l f (echo {} | awk \'{print $2}\'); if test "$s" = "??"; git diff --no-index --color=always /dev/null $f; else; git diff HEAD --color=always -- $f; end'

    set -l selected (git status --porcelain | \
        env SHELL=fish fzf --multi \
            --prompt="Select files to edit: " \
            --preview="$preview_cmd" \
            --preview-window=right:60%)

    set -l files
    for line in $selected
        set -a files (echo $line | awk '{print $2}')
    end

    if test -n "$files"
        nvim $files
    end

    popd
end
