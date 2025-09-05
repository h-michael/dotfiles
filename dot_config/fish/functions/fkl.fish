function fkl -d "View logs from selected Kubernetes container"
    eval (_fkp | awk '{print "kubectl logs -f " $1 " --container " $2}')
end
