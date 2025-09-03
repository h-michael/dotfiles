function fkl
  eval (_fk | awk '{print "kubectl logs -f " $1 " --container " $2}')
end