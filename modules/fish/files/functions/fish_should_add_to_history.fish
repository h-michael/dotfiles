function fish_should_add_to_history
    # Skip commands starting with whitespace
    if string match -qr '^\s' -- $argv[1]
        return 1
    end

    # Skip non-existent commands
    set -l cmd (string split ' ' -- $argv[1])[1]
    if not type -q -- $cmd
        return 1
    end

    return 0
end
