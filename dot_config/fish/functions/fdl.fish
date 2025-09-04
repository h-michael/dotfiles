function fdl -d "Select Docker container and see the logs of the container"
  _fdp -m | awk '{print $1}' | xargs docker logs $argv
end
