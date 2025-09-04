function _fkp -d "List Kubernetes pods and containers for selection"
  kubectl get pods -o go-template --template='{{range .items}}{{$item := .}}{{range .spec.containers}}{{$item.metadata.name}}{{"\t"}}{{.name}}{{"\n"}}{{end}}{{end}}' \
    | sort | column -t | fzf $argv
end

