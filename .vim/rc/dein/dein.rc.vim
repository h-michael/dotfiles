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

call dein#load_toml('~/.vim/rc/dein/dein.toml', {'lazy': 0})
call dein#load_toml('~/.vim/rc/dein/dein_lang.toml', {'lazy': 0})
call dein#load_toml('~/.vim/rc/dein/deinlazy.toml', {'lazy' : 1})
call dein#load_toml('~/.vim/rc/dein/deinlazy_lang.toml', {'lazy' : 1})
call dein#load_toml('~/.vim/rc/dein/deinft.toml')

let s:vimrc_local = '~/ghq/github.com/h-michael/'
if s:vimrc_local !=# ''
  " Load develop version plugins.
  call dein#local(fnamemodify(s:vimrc_local, ':h'),
        \ {'frozen': 1, 'merged': 0},
        \ ['debug-client-nvim', 'nvim-luvlsp'])
endif

if dein#tap('deoplete.nvim') && has('nvim')
  call dein#disable('neocomplete.vim')
endif
call dein#end()

call dein#save_state()

if has('vim_starting') && dein#check_install()
  " Installation check.
  call dein#install()
endif

