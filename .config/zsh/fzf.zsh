#!/bin/zsh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
export FZF_DEFAULT_OPTS='--reverse'
export FZF_CTRL_T_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
export FZF_CTRL_T_OPTS='--preview "bat  --color=always --style=header,grid --line-range :100 {}"'

# fe [FUZZY PATTERN] - Open the selected file with the default editor
#   - Bypass fuzzy finder if there's only one match (--select-1)
#   - Exit if there's no match (--exit-0)
function fe() {
  local file=(fzf --query="$1" --select-1 --exit-0)
  [ -n $file ] && nvim $file
}

## fd - cd to selected directory
# function fd {
#   local dir=$(find {1:-*} -path '*/\.*' -prune \
#                   -o -type d -print 2> /dev/null | fzf +m)
#   cd $dir
# }

# ssh to ec2 instance
function fsec2() {
  local IP=$(lsec2 $argv | fzf-tmux | awk -F "\t" '{print $2}')
  if [ $status -eq 0 -a "$IP" != "" ]; then
      echo ">>> SSH to $IP"
      ssh $IP
  fi
}

## fkill - kill process
function fkill() {
  ps -ef | sed 1d | fzf -m | awk '{print $2}' | xargs kill -9
}

## select repository
function frepo() {
  local dir=$(ghq list 2> /dev/null | fzf-tmux +m)
  cd $(ghq root)/$dir
}

## remove repository
function frmrepo() {
  ghq list --full-path 2> /dev/null | fzf-tmux --multi | xargs rm -rf
}

# fzf for git
function fgc() {
  git branch 2> /dev/null | fzf-tmux --reverse | xargs git checkout
}

function fgdb() {
  git branch 2> /dev/null | fzf-tmux --multi | xargs git branch -D
}

function fga() {
  git status -s 2> /dev/null | grep -e '^ M ' | sed -e 's/^ M //' | fzf-tmux --multi | xargs git add && git status -s
}

function fgr() {
  git status -s 2> /dev/null | grep -e '^M ' | sed -e 's/^M //' | fzf-tmux --multi | xargs git reset && git status -s
}

function gitaddm() {
  git status -s | grep -v 'M ' | sed -e 's/^\?\? //' | xargs git add
}

function fpl() {
  pacman -Qq | fzf --preview 'pacman -Qil {}' --layout=reverse --bind 'enter:execute(pacman -Qil() {} | less)'
}

function reposize() {
  local dirs=$(ghq list -p)
  for dir in $dirs
  do
    local dir_size=$(du -sm $dir)
    echo "$dir: $dir_size"
  done
}

function lsize() {
  local dirs=$(ls -a)
  for dir in $dirs
  do
    local dir_size=$(du -sm $dir)
    echo "$dir: $dir_size"
  done
}
