# Hook initialization

# direnv is critical for defining the environment for both interactive and
# non-interactive shells (e.g., for tools like gemini-cli).
# The hook itself is lightweight.
direnv hook fish | source

# The following hooks are for interactive convenience only and can be skipped
# in non-interactive shells to speed up startup.
if status is-interactive
    if not set -q __fish_interactive_hooks_initialized
        starship init fish | source
        atuin init fish | source
        zoxide init fish | source
        kabu init fish | source
        set -g __fish_interactive_hooks_initialized 1
    end

    # Starship transient prompt - simplifies previous prompts in history
    function starship_transient_prompt_func
        starship module character
    end
    enable_transience
end
