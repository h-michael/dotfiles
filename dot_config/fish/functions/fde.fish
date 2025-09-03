function fde -d "Select Docker container and login to the container" -a shell
  set shell_path (_get-shell-path $shell)
  eval (_fdp | awk -v shell="$shell_path" '{print "docker exec -it " $1 " " shell}')
end