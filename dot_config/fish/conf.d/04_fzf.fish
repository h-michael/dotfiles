# fzf config

set -x FZF_DEFAULT_COMMAND 'rg --files --hidden --follow --glob "!.git/*"'
set -x FZF_CTRL_T_COMMAND 'rg --files --hidden --follow --glob "!.git/*"'
set -x FZF_CTRL_T_OPTS '--preview "bat  --color=always --style=header,grid --line-range :100 {}"'
set -x FZF_DEFAULT_OPTS "--reverse \
  --highlight-line \
  --info=inline-right \
  --ansi \
  --layout=reverse \
  --border=none \
  --color=bg+:#283457 \
  --color=bg:#16161e \
  --color=border:#27a1b9 \
  --color=fg:#c0caf5 \
  --color=gutter:#16161e \
  --color=header:#ff9e64 \
  --color=hl+:#2ac3de \
  --color=hl:#2ac3de \
  --color=info:#545c7e \
  --color=marker:#ff007c \
  --color=pointer:#ff007c \
  --color=prompt:#2ac3de \
  --color=query:#c0caf5:regular \
  --color=scrollbar:#27a1b9 \
  --color=separator:#ff9e64 \
  --color=spinner:#ff007c \
"

function fdh
  history | fzf | read -l item; and history delete --prefix "$item"
end

# fe [FUZZY PATTERN] - Open the selected file with the default editor
#   - Bypass fuzzy finder if there's only one match (--select-1)
#   - Exit if there's no match (--exit-0)
function fe
  set file (fzf --query="$1" --select-1 --exit-0)
  [ -n $file ]; and nvim $file
end

# ssh to ec2 instance
function fsec2
  set IP (lsec2 $argv | fzf | awk -F "\t" '{print $2}')
  if [ $status -eq 0 -a "$IP" != "" ]
      echo ">>> SSH to $IP"
      ssh $IP
  end
end

function fkill -d "Kill selected process"
  ps -ef | sed 1d | fzf -m | awk '{print $2}' | xargs kill -9
end

function frepo -d "cd to selected git repository"
  set dir (ghq list | fzf +m)
  cd (ghq root)/$dir
end

function frmrepo -d "Remove selected git repository"
  ghq list --full-path | fzf --multi | xargs rm -rf
end

function fgc -d "git checkout selected branch"
  git branch | fzf --reverse | xargs git checkout
end

function fgdb -d "git delete selected branch"
  git branch | fzf --multi | xargs git branch -D
end

function fgadd -d "git add selected files"
  git status -s | grep -e '^ M ' | sed -e 's/^ M //' | fzf --multi | xargs git add; and git status -s
end

function fgreset -d "git reset selected files"
  git status -s | grep -e '^M ' | sed -e 's/^M //' | fzf --multi | xargs git reset; and git status -s
end

function fgss -d "git stash show selected stash"
  git stash list | fzf --reverse --preview "echo {} | awk -F ':' '{print \$1}' | xargs git stash show -p | bat --color=always --style=numbers" | awk -F ':' '{print $1}'
end

function gitaddm -d "git add modified files"
  git status -s | grep -v 'M ' | sed -e 's/^\?\? //' | xargs git add
end

function fpl
  pacman -Qq | fzf --preview 'pacman -Qil {}' --layout=reverse --bind 'enter:execute(pacman -Qil {} | less)'
end

function reposize
  set dirs (ghq list -p)
  for dir in $dirs
    set dir_size (du -sm $dir)
    echo "$dir: $dir_size"
  end
end

function lsize
  set dirs (ls -a)
  for dir in $dirs
    set dir_size (du -sm $dir)
    echo "$dir: $dir_size"
  end
end

# switch gcloud configurations
function fga
  gcloud config configurations list --format="table[no-heading] (name,is_active,name,properties.core.account,properties.core.project)" | fzf | awk '{print $1}' | xargs gcloud config configurations activate
end

function _get_shell_path -a shell
  switch "$shell"
    case bash
      echo "/bin/bash"
    case zsh
      echo "/bin/zsh"
    case fish
      echo "/usr/bin/fish"
    case sh
      echo "/bin/sh"
    case ""
      echo "/bin/sh"
    case "*"
      echo "/bin/sh"
  end
end

function _fk
 kubectl get pods -o go-template --template='{{range .items}}{{$item := .}}{{range .spec.containers}}{{$item.metadata.name}}{{"\t"}}{{.name}}{{"\n"}}{{end}}{{end}}' \
    | sort | column -t | fzf
end

function fke -d "Select K8S container and login to the container" -a shell
  set shell_path (_get_shell_path $shell)
  eval (_fk | awk -v shell="$shell_path" '{print "kubectl exec -it " $1 " --container " $2 " -- " shell}')
end

function fkl
  eval (_fk | awk '{print "kubectl logs -f " $1 " --container " $2}')
end

function fgssh
  eval (gcloud compute instances list --format="table[no-heading] (name,zone,status)" | fzf | awk '{printf "gcloud compute ssh \"%s\" --zone \"%s\" --tunnel-through-iap", $1, $2}')
end

function fav -d "Select AWS profile"
  aws-vault exec (aws-vault list | sed '1,2d' | fzf --prompt="Select profile" | awk '{print $1}')
end

function fec2ssm -d "Select EC2 instance and start SSM session"
  aws ec2 describe-instances | jq -r '.Reservations[].Instances[] | [.InstanceId, .KeyName] | @tsv' | fzf | awk '{print $1}' | xargs aws ssm start-session --target
end

function fecse -d "Select ECS container and execute command"
  set CLUSTER_ARN (aws ecs list-clusters | jq -r '.clusterArns[]' | fzf)
  set SERVICE_ARN (aws ecs list-services --cluster $CLUSTER_ARN | jq -r '.serviceArns[]' | fzf)
  set SERVICE_NAME (aws ecs describe-services --cluster $CLUSTER_ARN --services $SERVICE_ARN | jq -r '.services[] | .serviceName')
  set TASK_ARN (aws ecs list-tasks --cluster $CLUSTER_ARN --service-name $SERVICE_NAME | jq -r '.taskArns[]' | fzf)
  set CONTAINER_NAME (aws ecs describe-tasks --cluster $CLUSTER_ARN --tasks $TASK_ARN | jq -r '.tasks[] | .containers[] | .name' | fzf)
  aws ecs execute-command --cluster $CLUSTER_ARN --task $TASK_ARN --container $CONTAINER_NAME --interactive --command "/bin/bash"
end

function _fdp
  docker ps --format "{{.ID}}\t{{.Image}}\t{{.Command}}\t{{.Status}}" | sort -k2 | column -t | fzf
end

function fds -d "Select Docker container and stop the container"
  _fdp | awk '{print $1}' | xargs docker stop
end

function fde -d "Select Docker container and login to the container" -a shell
  set shell_path (_get_shell_path $shell)
  eval (_fdp | awk -v shell="$shell_path" '{print "docker exec -it " $1 " " shell}')
end

function fts -d "Select tmux session and switch to it"
  set session (tmux list-sessions -F "#{session_name}: #{session_windows} windows (created #{session_created_string}) #{?session_attached,(attached),}" | fzf \
    --layout=reverse \
    --border=rounded \
    --no-multi \
    --info=inline \
    --prompt="Select tmux session: " \
    --preview='fish -c "set session_name (echo {} | cut -d: -f1); set current_session (tmux display-message -p \"#S\" 2>/dev/null); if test \"\$session_name\" = \"\$current_session\"; echo \"Current Session\"; else; tmux capture-pane -t \"\$session_name\" -e -p 2>/dev/null | bat --color=always --style=plain; or echo \"Session preview unavailable\"; end"' \
    --preview-window=down:70%:wrap | cut -d: -f1)
  if test -n "$session"
    if set -q TMUX
      tmux switch-client -t "$session"
    else
      tmux attach-session -t "$session"
    end
  end
end

function ftw -d "Select tmux window and switch to it"
  set window (tmux list-windows -F "#{window_index}: #{window_name} (#{window_panes} panes) #{?window_active,(active),}" | fzf \
    --layout=reverse \
    --border=rounded \
    --no-multi \
    --info=inline \
    --prompt="Select tmux window: " \
    --preview='fish -c "set window_index (echo {} | cut -d: -f1); set current_window (tmux display-message -p \"#I\" 2>/dev/null); set session_name (tmux display-message -p \"#S\" 2>/dev/null); if test \"\$window_index\" = \"\$current_window\"; echo \"Current Window\"; else; tmux capture-pane -t \"\$session_name:\$window_index\" -e -p 2>/dev/null | bat --color=always --style=plain; or echo \"Window preview unavailable\"; end"' \
    --preview-window=down:70%:wrap | cut -d: -f1)
  if test -n "$window"
    tmux select-window -t "$window"
  end
end

function ftsw -d "Switch tmux session or window"
  set choice (echo -e "Switch tmux session\nChange tmux window" | fzf \
    --layout=reverse \
    --border=rounded \
    --no-multi \
    --info=inline \
    --prompt="Switch tmux session or window: ")
  
  if test -n "$choice"
    switch "$choice"
      case "Switch tmux session"
        fts
      case "Change tmux window"
        ftw
    end
  end
end
