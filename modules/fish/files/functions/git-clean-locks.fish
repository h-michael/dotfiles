function git-clean-locks -d "Remove stale git index.lock files"
    set -l git_dir (git rev-parse --git-dir 2>/dev/null)
    if test $status -ne 0
        echo "Not a git repository"
        return 1
    end

    set -l found 0

    # Main index.lock
    if test -f "$git_dir/index.lock"
        echo "Removing $git_dir/index.lock"
        rm "$git_dir/index.lock"
        set found (math $found + 1)
    end

    # Submodules
    for lock in (find "$git_dir/modules" -name "index.lock" 2>/dev/null)
        echo "Removing $lock"
        rm "$lock"
        set found (math $found + 1)
    end

    # Worktrees
    for lock in (find "$git_dir/worktrees" -name "index.lock" 2>/dev/null)
        echo "Removing $lock"
        rm "$lock"
        set found (math $found + 1)
    end

    if test $found -eq 0
        echo "No index.lock files found"
    else
        echo "Removed $found index.lock file(s)"
    end
end
