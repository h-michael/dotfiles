# fzf config

set -x FZF_DEFAULT_COMMAND 'rg --files --hidden --follow --glob "!.git/*"'
set -x FZF_DEFAULT_OPTS '--reverse'
set -x FZF_CTRL_T_COMMAND 'rg --files --hidden --follow --glob "!.git/*"'
set -x FZF_CTRL_T_OPTS '--preview "bat  --color=always --style=header,grid --line-range :100 {}"'

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

function _fk
  kubectl get pods -o go-template --template="{{range .items}}{{\$item := .}}{{range .spec.containers}}{{\$item.metadata.name}}{{`"\t"`}}{{.name}}{{`"\n"`}}{{end}}{{end}}" | sort | fzf
end

function fke
  eval (_fk | awk '{print "kubectl exec -it " $1 " --container " $2 " -- /bin/sh"}')
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
