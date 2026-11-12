# Route kubectl through kubecolor for colorized output
# https://kubecolor.github.io/setup/shells/fish/
if type -q kubecolor
    # Completions for the wrapper come from kubectl's vendor completion
    # file in the Nix profile, which fish autoloads on first use.
    function kubectl --wraps kubectl
        command kubecolor $argv
    end
end
