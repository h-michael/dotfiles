function _fk -d "List Kubernetes pods and containers for selection"
  kubectl get pods -o go-template --template='{{range .items}}{{$item := .}}{{range .spec.containers}}{{$item.metadata.name}}{{"	"}}{{.name}}{{""}}{{end}}{{end}}' \
    | sort | column -t | fzf
end
