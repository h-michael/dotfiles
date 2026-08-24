function tns -d "Create (or switch to) a tmux session named after the given name or cwd"
    set -l name $argv[1]
    if test -z "$name"
        set name (basename $PWD)
    end

    if not tmux has-session -t "$name" 2>/dev/null
        tmux new-session -d -s "$name" -c "$PWD"
    end

    if set -q TMUX
        tmux switch-client -t "$name"
    else
        tmux attach-session -t "$name"
    end
end
