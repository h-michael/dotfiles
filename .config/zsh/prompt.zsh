#!/bin/zsh

setopt promptsubst
autoload zsh/terminfo

local _current_dir="%{$fg_bold[blue]%}%30<...<%~%<<%{$reset_color%} "

if [[ $UID -eq 0 ]]; then
  local user_host='%{$terminfo[bold]$fg[red]%}%n@%m %{$reset_color%}'
else
  local user_host='%{$terminfo[bold]$fg[green]%}%n@%m %{$reset_color%}'
fi

if [[ $USER == "root" ]]; then
  CARETCOLOR="red"
else
  CARETCOLOR="white"
fi

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "

MODE_INDICATOR="%{$fg_bold[red]%}<%{$reset_color%} "

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=white'

PROMPT="${user_host}${_current_dir}\$(git_prompt_info)\$(vi_mode_prompt_info)%(?.%{$fg[green]%}.%{$fg[red]%})%B$%b "
RPROMPT="%{$fg[white]%}%{$fg[yellow]%}%D %T%{$fg[white]%}%{$reset_color%}"
