" dein configurations.

let g:dein#install_progress_type = 'title'
if has('nvim')
  let s:path = expand('$CACHE/dein-nvim')
else
  let s:path = expand('$CACHE/dein-vim')
endif

if !dein#load_state(s:path)
  finish
endif

call dein#begin(s:path, expand('<sfile>'))

call dein#load_toml('~/.vim/rc/plugins/default.rc.toml', {'lazy': 0})
call dein#load_toml('~/.vim/rc/plugins/lazy.rc.toml', {'lazy' : 1})
call dein#load_toml('~/.vim/rc/plugins/lazy_lang.rc.toml', {'lazy' : 1})
call dein#load_toml('~/.vim/rc/plugins/filetype.rc.toml')

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

