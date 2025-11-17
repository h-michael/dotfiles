function fts -d "Select tmux session and switch to it"
    set session (tmux list-sessions -F "#{?session_attached,* ,  }#{session_name}: #{session_windows} windows" | fzf \
    --layout=reverse \
    --border=rounded \
    --no-multi \
    --info=inline \
    --prompt="Select tmux session: " \
    --preview='bash -c "session_name=\$(echo {} | sed \"s/^[* ] *//\" | cut -d: -f1); echo \"Processes: \$(tmux list-panes -t \"\$session_name\" -F \"#{pane_current_command}\" 2>/dev/null | sort -u | paste -sd, -)\"; echo; tmux capture-pane -t \"\$session_name\" -e -p 2>/dev/null | bat --color=always --style=plain || echo \"Session preview unavailable\""' \
    --preview-window=down:85%:wrap | sed 's/^[* ] *//' | cut -d: -f1)
    if test -n "$session"
        if set -q TMUX
            tmux switch-client -t "$session"
        else
            tmux attach-session -t "$session"
        end
    end
end
