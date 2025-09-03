function fke -d "Select K8S container and login to the container" -a shell
  set shell_path (_get-shell-path $shell)
  eval (_fk | awk -v shell="$shell_path" '{print "kubectl exec -it " $1 " --container " $2 " -- " shell}')
end