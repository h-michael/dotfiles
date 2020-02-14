# fzf config

set -x FZF_DEFAULT_COMMAND 'rg --files --hidden --follow --glob "!.git/*"'
set -x FZF_DEFAULT_OPTS '--reverse'
set -x FZF_CTRL_T_COMMAND 'rg --files --hidden --follow --glob "!.git/*"'
set -x FZF_CTRL_T_OPTS '--preview "bat  --color=always --style=header,grid --line-range :100 {}"'

# fe [FUZZY PATTERN] - Open the selected file with the default editor
#   - Bypass fuzzy finder if there's only one match (--select-1)
#   - Exit if there's no match (--exit-0)
function fe
  set file (fzf --query="$1" --select-1 --exit-0)
  [ -n $file ]; and nvim $file
end

## fd - cd to selected directory
# function fd
#   set dir (find {1:-*} -path '*/\.*' -prune \
#                   -o -type d -print 2> /dev/null | fzf +m); and
#   cd $dir
# end

# ssh to ec2 instance
function fsec2
  set IP (lsec2 $argv | fzf | awk -F "\t" '{print $2}')
  if [ $status -eq 0 -a "$IP" != "" ]
      echo ">>> SSH to $IP"
      ssh $IP
  end
end

## fkill - kill process
function fkill
  ps -ef | sed 1d | fzf -m | awk '{print $2}' | xargs kill -9
end

## select repository
function frepo
  set dir (ghq list ^ /dev/null | fzf +m)
  cd (ghq root)/$dir
end

## remove repository
function frmrepo
  ghq list --full-path ^ /dev/null | fzf --multi | xargs rm -rf
end

# fzf for git

function fgc
  git branch ^ /dev/null | fzf --reverse | xargs git checkout
end

function fgdb
  git branch ^ /dev/null | fzf --multi | xargs git branch -D
end

function fga
  git status -s ^ /dev/null | grep -e '^ M ' | sed -e 's/^ M //' | fzf --multi | xargs git add; and git status -s
end

function fgr
  git status -s ^ /dev/null | grep -e '^M ' | sed -e 's/^M //' | fzf --multi | xargs git reset; and git status -s
end

function gitaddm
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
