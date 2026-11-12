# Hook initialization

# Interactive only: these hooks run on prompt events, which never fire in
# non-interactive shells (direnv's hook included), so loading them there
# only costs startup time.
if status is-interactive
    direnv hook fish | source

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
