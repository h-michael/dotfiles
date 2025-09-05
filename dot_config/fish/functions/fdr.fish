function fdr -d "Select Docker container and remove the container"
    docker container ls -a -f status=exited --format "{{.ID}}	{{.Image}}	{{.Command}}" | fzf -m | awk '{print $1}' | xargs docker rm
end
