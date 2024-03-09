#!/bin/zsh

if is_linux; then
  alias ls='ls --color'
fi
alias mnvim="nvim -u ~/.minimal_nvimrc"
alias mvim="vim -u ~/.minimal_vimrc"
alias nvim-lsp_log="nvim $LSP_LOG_PATH"
alias rm-lsp_log="rm $LSP_LOG_PATH"

# Makefile use /bin/sh as default shell. rtx doesn't use shims,
# so need to specify zsh to activate rtx.
alias make="make SHELL=/bin/zsh"
