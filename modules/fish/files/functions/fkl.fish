function fkl -d "View logs from selected Kubernetes container"
    set -l selection (_fkp)
    if test -z "$selection"
        return 1
    end

    set -l pod (echo $selection | awk '{print $1}')
    set -l container (echo $selection | awk '{print $2}')

    kubectl logs -f $pod --container $container $argv
end
