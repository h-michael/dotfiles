# Format directory name display for Claude Code statusline
# Args:
#   $argv[1] - current directory path
#   $argv[2] - number of directory levels to display (optional, default: full path)
# Returns:
#   Plain text directory name, or empty string if invalid
#
# Examples:
#   cc_statusline_directory "/Users/user/.local/share/dotfiles/chezmoi" → "/Users/user/.local/share/dotfiles/chezmoi"
#   cc_statusline_directory "/Users/user/.local/share/dotfiles/chezmoi" 1 → "chezmoi"
#   cc_statusline_directory "/Users/user/.local/share/dotfiles/chezmoi" 3 → "~/share/dotfiles/chezmoi" (if under $HOME)
#   cc_statusline_directory "/usr/local/share/something" 2 → "⋯/share/something" (if not under $HOME)

function cc_statusline_directory
    set -l current_dir $argv[1]
    set -l depth $argv[2]

    if test -z "$current_dir"
        return
    end

    # If no depth specified or depth <= 0, show full path
    if test -z "$depth"; or test "$depth" -le 0
        echo $current_dir
        return
    end

    # Split path by '/' and filter out empty strings
    set -l path_parts (string split "/" $current_dir | string match -v "")
    set -l num_parts (count $path_parts)

    # If depth exceeds or equals number of parts, show full path without prefix
    if test "$depth" -ge "$num_parts"
        echo $current_dir
        return
    end

    # Take the last N parts
    set -l start_idx (math "$num_parts - $depth + 1")
    set -l dir_name (string join "/" $path_parts[$start_idx..-1])

    # Path was trimmed, add appropriate prefix
    # Check if the trimmed path would be directly under $HOME
    # by reconstructing the full path with $HOME prefix
    if string match -q "$HOME/*" $current_dir
        # Check if $HOME/<trimmed_path> equals the actual full path
        set -l reconstructed_path "$HOME/$dir_name"
        if test "$reconstructed_path" = "$current_dir"
            # Trimmed path is directly under $HOME
            echo "~/$dir_name"
        else
            # Trimmed path skips intermediate directories
            echo "⋯/$dir_name"
        end
    else
        # Not under $HOME at all
        echo "⋯/$dir_name"
    end
end
