function _fdp
  docker ps --format "{{.ID}}	{{.Image}}	{{.Command}}	{{.Status}}" | sort -k2 | column -t | fzf
end