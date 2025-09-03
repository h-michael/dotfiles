function fkl -d "View logs from selected Kubernetes container"
  eval (_fk | awk '{print "kubectl logs -f " $1 " --container " $2}')
end