function tss --description "Start tmux and attach to restored session"
    # If tmux server is already running, select session with fzf
    if tmux list-sessions &>/dev/null
        fts
        return
    end

    # Start tmux (continuum will restore sessions)
    tmux new-session -d -s _temp_

    # Wait a moment for continuum to restore
    sleep 0.5

    # Get list of sessions (excluding our temp session)
    set -l sessions (tmux list-sessions -F '#{session_name}' | grep -v '^_temp_$')

    if test (count $sessions) -gt 0
        # Kill temp session, then select from restored sessions with fzf
        tmux kill-session -t _temp_ 2>/dev/null
        fts
    else
        # No restored sessions, rename temp to main and attach
        tmux rename-session -t _temp_ main
        tmux attach -t main
    end
end
