# Hook initialization - only once per fish process
# Loaded last in conf.d to ensure all PATH and environment setup is complete

if not set -q __fish_hooks_initialized
    starship init fish | source
    direnv hook fish | source
    set -g __fish_hooks_initialized 1
end

# Starship transient prompt - simplifies previous prompts in history
function starship_transient_prompt_func
    starship module character
end
enable_transience
