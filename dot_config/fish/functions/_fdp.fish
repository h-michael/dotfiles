function _fdp -d "List Docker containers for selection"
    docker ps --format "{{.ID}}	{{.Image}}	{{.Command}}	{{.Status}}" | sort -k2 | column -t | fzf $argv
end
