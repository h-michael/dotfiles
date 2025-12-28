function ftw -d "Select tmux window and switch to it"
    set window (tmux list-windows -F "#{window_index}: #{window_name} (#{window_panes} panes) #{?window_active,(active),}" | fzf \
    --layout=reverse \
    --border=rounded \
    --no-multi \
    --info=inline \
    --prompt="Select tmux window: " \
    --preview='fish -c "set window_index (echo {} | cut -d: -f1); set current_window (tmux display-message -p \"#I\" 2>/dev/null); set session_name (tmux display-message -p \"#S\" 2>/dev/null); if test \"$window_index\" = \"$current_window\"; echo \"Current Window\"; else; tmux capture-pane -t \"$session_name:$window_index\" -e -p 2>/dev/null | bat --color=always --style=plain; or echo \"Window preview unavailable\"; end"' \
    --preview-window=down:70%:wrap | cut -d: -f1)
    if test -n "$window"
        tmux select-window -t "$window"
    end
end
