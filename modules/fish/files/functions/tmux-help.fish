function tmux-help --description "Show tmux keybindings and execute selected one"
    # Show keybindings with notes (exclude copy-mode entries)
    set -l selected (tmux list-keys -N | grep -v "^copy-mode" | fzf --reverse --header "Enter: execute, Esc: cancel")

    if test -z "$selected"
        return
    end

    # Parse format: "C-s Tab     description" (prefix) or "    M-y     description" (root)
    set -l table ""
    set -l key ""

    if string match -qr '^\s+\S' -- "$selected"
        # Root table: "    M-y     ..." (starts with spaces)
        set table "root"
        set key (string trim -l "$selected" | string split " " | head -1)
    else if string match -qr '^C-s\s' -- "$selected"
        # Prefix table: "C-s Tab     ..."
        set table "prefix"
        # Extract second word (the key after C-s)
        set key (echo "$selected" | awk '{print $2}')
    else
        return
    end

    if test -z "$key"
        return
    end

    # Find the exact line in list-keys and extract command
    # Format: bind-key [-r] [-N "..."] -T table key command...
    set -l cmd ""
    for line in (tmux list-keys | grep -F " $key ")
        # Check if this line has the right table
        if echo "$line" | grep -qE "\-T\s+$table\s"
            # Extract command: everything after the key
            # Use perl for robust parsing
            set cmd (echo "$line" | perl -pe '
                s/^bind-key\s+//;
                s/-r\s+//;
                s/-N\s+"[^"]*"\s+//;
                s/-T\s+\S+\s+//;
                s/^\S+\s+//;  # remove the key itself
            ')
            break
        end
    end

    if test -n "$cmd"
        # Create executable script
        echo "#!/bin/sh" > /tmp/tmux-help-cmd.sh
        echo "sleep 0.2" >> /tmp/tmux-help-cmd.sh
        echo "tmux $cmd" >> /tmp/tmux-help-cmd.sh
        chmod +x /tmp/tmux-help-cmd.sh
        # Execute in background
        tmux run-shell -b /tmp/tmux-help-cmd.sh
    end
end
