function fds -d "Select Docker container and stop the container"
    _fdp -m | awk '{print $1}' | xargs docker stop
end
