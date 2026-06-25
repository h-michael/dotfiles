# Route kubectl through kubecolor for colorized output
# https://kubecolor.github.io/setup/shells/fish/
if type -q kubecolor
    function kubectl --wraps kubectl
        command kubecolor $argv
    end

    # Reuse kubectl's native completions for the wrapper. `command` bypasses
    # the function above so we source the real binary's output, not kubecolor's.
    if not set -q __kubecolor_completions_initialized
        command kubectl completion fish | source
        set -g __kubecolor_completions_initialized 1
    end
end
