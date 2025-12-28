function fta -d "Attach to a selected tmux session"
    # Check if tmux server is running and sessions exist
    if not tmux list-sessions 2>/dev/null
        echo "No tmux sessions found"
        return 1
    end

    # Select session with fzf
    set -l session (tmux list-sessions -F "#{session_name}: #{session_windows} windows (#{session_attached} attached)" | \
        fzf --prompt="Select session: " | \
        string split -f1 ":")

    # Exit if selection was cancelled
    if test -z "$session"
        return 0
    end

    # Attach to selected session
    tmux attach-session -t $session
end
