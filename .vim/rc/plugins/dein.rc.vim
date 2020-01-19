" dein configurations.

let g:dein#auto_recache = 1

let g:dein#install_progress_type = 'title'
if has('nvim')
  let s:path = expand('$CACHE/dein-nvim')
else
  let s:path = expand('$CACHE/dein-vim')
endif

if !dein#load_state(s:path)
  finish
endif

let s:default_toml = '~/.vim/rc/plugins/default.rc.toml'
let s:lazy_toml = '~/.vim/rc/plugins/lazy.rc.toml'
let s:nvim_lsp_toml = '~/.vim/rc/plugins/nvim_lsp.rc.toml'
let s:ftplugin_toml = '~/.vim/rc/plugins/ftplugin.rc.toml'

call dein#begin(s:path, [
      \ expand('<sfile>'), s:default_toml, s:lazy_toml, s:nvim_lsp_toml, s:ftplugin_toml
      \ ])

call dein#load_toml(s:default_toml, {'lazy': 0})
call dein#load_toml(s:lazy_toml, {'lazy' : 1})
if has("nvim-0.5")
  call dein#load_toml(s:nvim_lsp_toml, {'lazy' : 1})
endif
call dein#load_toml(s:ftplugin_toml)

let s:vimrc_local = '~/go/src/github.com/h-michael/'
if s:vimrc_local !=# ''
  " Load develop version plugins.
  call dein#local(fnamemodify(s:vimrc_local, ':h'),
        \ {'frozen': 1, 'merged': 0},
        \ [])
endif

call dein#end()

call dein#save_state()

if has('vim_starting') && dein#check_install()
  call dein#install()
endif

