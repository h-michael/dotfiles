function fkl -d "View logs from selected Kubernetes container (use --gc to format Google Cloud structured logs)"
    set -l parse_mode false
    set -l kubectl_args

    # Parse arguments
    for arg in $argv
        switch $arg
            case --gc
                set parse_mode true
            case '*'
                set -a kubectl_args $arg
        end
    end

    set -l selection (_fkp)
    if test -z "$selection"
        return 1
    end

    set -l pod (echo $selection | awk '{print $1}')
    set -l container (echo $selection | awk '{print $2}')

    if test "$parse_mode" = true
        # Parse structured logs (Google Cloud Logging JSON format)
        kubectl logs -f $pod --container $container $kubectl_args | while read -l line
            # Try to parse as JSON, if it fails output the line as-is
            echo $line | jq -r '"\(.time | split("T")[1] | .[0:12]) [\(.severity | .[0:1])] \(.message)"' 2>/dev/null || echo $line
        end
    else
        kubectl logs -f $pod --container $container $kubectl_args
    end
end
