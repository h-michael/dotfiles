# https://github.com/Ladicle/fish-kubectl-prompt

set ENABLE_PROMPT_STATUS 0

function kubectl_status
  [ -z "$KUBECTL_PROMPT_ICON" ]; and set -l KUBECTL_PROMPT_ICON "⎈"
  [ -z "$KUBECTL_PROMPT_SEPARATOR" ]; and set -l KUBECTL_PROMPT_SEPARATOR "/"
  set -l config $KUBECONFIG
  [ -z "$config" ]; and set -l config "$HOME/.kube/config"
  if [ ! -f $config ]
    return
  end

  set -l ctx (cat ~/.kube/config | grep current-context | awk '{print $2}')
  if [ $status -ne 0 ]
    echo (set_color red)$KUBECTL_PROMPT_ICON" "(set_color white)"no context"
    return
  end

  set -l ns (kubectl config view -o "jsonpath={.contexts[?(@.name==\"$ctx\")].context.namespace}")
  [ -z $ns ]; and set -l ns 'default'

  echo (set_color cyan)$KUBECTL_PROMPT_ICON" "(set_color white)"$ctx$KUBECTL_PROMPT_SEPARATOR$ns"
end

function show_kube_context
  set -l config $KUBECONFIG
  [ -z "$config" ]; and set -l config "$HOME/.kube/config"
  if [ ! -f $config ]
    return
  end

  set -l ctx (cat $HOME/.kube/config | grep current-context | awk '{print $2}' 2>/dev/null)
  if [ $status -ne 0 ]
    echo (set_color white)"no kube context"
    return
  end

  echo $ctx
end

function toggle_status
  if test $ENABLE_PROMPT_STATUS -eq 0
    set ENABLE_PROMPT_STATUS 1
  else
    set ENABLE_PROMPT_STATUS 0
  end
end

function gcloud_active_config
  cat $XDG_CONFIG_HOME/gcloud/active_config
end

function fish_right_prompt
  if test $ENABLE_PROMPT_STATUS -ne 0; return; end
  echo (gcloud_active_config)" | "(show_kube_context)
end
