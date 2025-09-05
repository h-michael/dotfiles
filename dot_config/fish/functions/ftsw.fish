function ftsw -d "Switch tmux session or window"
    set choice (echo -e "Switch tmux session\nChange tmux window" | fzf \
    --layout=reverse \
    --border=rounded \
    --no-multi \
    --info=inline \
    --prompt="Switch tmux session or window: ")

    if test -n "$choice"
        switch "$choice"
            case "Switch tmux session"
                fts
            case "Change tmux window"
                ftw
        end
    end
end
