function fgconf -d "Open conflicted files in editor interactively"
    # Get conflicted files with status from git status
    set -l conflict_list (git status --short | grep -E '^(UU|AA)')

    if test -z "$conflict_list"
        echo "No conflicted files found (both modified or both added)"
        return 0
    end

    # Format: "UU path/to/file" -> "[both modified] path/to/file"
    # Format: "AA path/to/file" -> "[both added] path/to/file"
    set -l formatted_list (printf "%s\n" $conflict_list | while read -l line
        set -l status_code (string sub -l 2 $line)
        set -l file_path (string sub -s 4 $line)

        switch $status_code
            case UU
                echo "[both modified] $file_path"
            case AA
                echo "[both added] $file_path"
        end
    end)

    # Select files with fzf
    set -l selected (printf "%s\n" $formatted_list | fzf --multi --prompt="Select conflicted files to edit: " --preview="git diff --color=always {2}" --preview-window=right:60%)

    if test -z "$selected"
        return 0
    end

    # Extract file paths (remove status prefix like "[both modified] ")
    set -l files (printf "%s\n" $selected | string replace -r '^\[[^\]]+\] ' '')

    # Open selected files in editor
    if test -n "$EDITOR"
        $EDITOR $files
    else
        # Fallback to nvim if $EDITOR is not set
        nvim $files
    end
end
