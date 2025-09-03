function fts -d "Select tmux session and switch to it"
  set session (tmux list-sessions -F "#{session_name}: #{session_windows} windows (created #{session_created_string}) #{?session_attached,(attached),}" | fzf \
    --layout=reverse \
    --border=rounded \
    --no-multi \
    --info=inline \
    --prompt="Select tmux session: " \
    --preview='fish -c "set session_name (echo {} | cut -d: -f1); set current_session (tmux display-message -p \"#S\" 2>/dev/null); if test \"$session_name\" = \"$current_session\"; echo \"Current Session\"; else; tmux capture-pane -t \"$session_name\" -e -p 2>/dev/null | bat --color=always --style=plain; or echo \"Session preview unavailable\"; end"' \
    --preview-window=down:70%:wrap | cut -d: -f1)
  if test -n "$session"
    if set -q TMUX
      tmux switch-client -t "$session"
    else
      tmux attach-session -t "$session"
    end
  end
end