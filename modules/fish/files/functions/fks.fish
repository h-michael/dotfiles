function fks -d "Switch Kubernetes context and namespace interactively"
    # Select context (cluster)
    set -l context (kubectx | fzf --prompt="Select context (cluster): " --height=40%)

    if test -z "$context"
        # User cancelled context selection
        return 0
    end

    # Switch to selected context
    kubectx $context

    # Check if context switch was successful
    if test $status -ne 0
        echo "Failed to switch context"
        return 1
    end

    # Get namespace list for the selected context (fastest method)
    set -l namespace (kubectl get ns -o name 2>/dev/null | sed 's|^namespace/||' | fzf --prompt="Select namespace: " --height=40%)

    if test -n "$namespace"
        # Switch to selected namespace
        kubens $namespace
    end
end
