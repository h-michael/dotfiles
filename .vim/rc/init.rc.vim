"---------------------------------------------------------------------------
" Initialize:
"

let s:is_windows = has('win32') || has('win64')

function! IsWindows() abort
  return s:is_windows
endfunction

function! IsMac() abort
  return !s:is_windows && !has('win32unix')
      \ && (has('mac') || has('macunix') || has('gui_macvim')
      \     || (!executable('xdg-open') && system('uname') =~? '^darwin'))
endfunction

" Setting of the encoding to use for a save and reading.
" Make it normal in UTF-8 in Unix.
if has('vim_starting') && &encoding !=# 'utf-8'
  if IsWindows() && !has('gui_running')
    set encoding=cp932
  else
    set encoding=utf-8
  endif
endif

if exists('&ambw')
  set ambw=double
endif

" Build encodings.
let &fileencodings = join(['utf-8', 'ucs-bom', 'iso-2022-jp-3', 'euc-jp', 'cp932'])

" Setting of terminal encoding.
if !has('gui_running') && IsWindows()
  " For system.
  set termencoding=cp932
endif

if has('multi_byte_ime')
  set iminsert=0 imsearch=0
endif

" Use English interface.
language message C

" Use <Leader> in global plugin.
" Use <LocalLeader> in filetype plugin.
if !exists('g:mapleader')
  let g:mapleader = ";"
endif
if !exists('g:maplocalleader')
  let g:maplocalleader = 'm'
endif


if IsWindows()
  " Exchange path separator.
   set shellslash
endif

let $CACHE = expand($XDG_CACHE_HOME)

if !isdirectory(expand($CACHE))
  call mkdir(expand($CACHE), 'p')
endif

if filereadable(expand('~/.secret_vimrc'))
  execute 'source' expand('~/.secret_vimrc')
endif

" Load dein.

if has('nvim')
  let s:dein_dir = finddir('dein.vim', '.;')
else
  let s:dein_dir = finddir('dein.vim', '.;')
endif
if s:dein_dir !=# '' || &runtimepath !~# '/dein.vim'
  if s:dein_dir ==# '' && &runtimepath !~# '/dein.vim'
    let s:dein_dir = expand('$CACHE/dein')
          \. '/repos/github.com/Shougo/dein.vim'
    if !isdirectory(s:dein_dir)
      execute '!git clone https://github.com/Shougo/dein.vim' s:dein_dir
    endif
  endif
  execute 'set runtimepath^=' . substitute(fnamemodify(s:dein_dir, ':p') , '/$', '', '')
endif

" Disable packpath
set packpath=


"---------------------------------------------------------------------------
" Disable default plugins

" Disable menu.vim
if has('gui_running')
   set guioptions=Mc
endif
