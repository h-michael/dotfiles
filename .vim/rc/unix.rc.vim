" For UNIX:
"

" Use sh.  It is faster
set shell=sh

" Set path.
let $PATH = expand('~/bin').':/usr/local/bin/:'.$PATH

if has('gui_running')
  finish
endif

if IsMac()
    let g:python_host_prog = '/usr/local/bin/python2'
    let g:python3_host_prog = '/usr/local/bin/python3'
else
    let g:python_host_prog = '/usr/bin/python2'
    let g:python3_host_prog = '/usr/bin/python3'
endif

"---------------------------------------------------------------------------
" For CUI:
"

if has('termguicolors')
  set termguicolors
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif

if !has('nvim')
  set term=xterm-256color

  let &t_ti .= "\e[?2004h"
  let &t_te .= "\e[?2004l"
  let &pastetoggle = "\e[201~"

  function! XTermPasteBegin(ret) abort
    setlocal paste
    return a:ret
  endfunction

  noremap <special> <expr> <Esc>[200~ s:XTermPasteBegin('0i')
  inoremap <special> <expr> <Esc>[200~ s:XTermPasteBegin('')
  cnoremap <special> <Esc>[200~ <nop>
  cnoremap <special> <Esc>[201~ <nop>

  " Optimize vertical split.
  " Note: Newest terminal is needed.
  " let &t_ti .= "\e[?6;69h"
  " let &t_te .= "\e7\e[?6;69l\e8"
  " let &t_CV = "\e[%i%p1%d;%p2%ds"
  " let &t_CS = "y"

  " Change cursor shape.
  let &t_SI = "\<Esc>]12;lightgreen\x7"
  let &t_EI = "\<Esc>]12;white\x7"
endif

" Using the mouse on a terminal.
if has('mouse') && !has('nvim')
   set mouse=a
  if has('mouse_sgr') || v:version > 703 ||
        \ v:version == 703 && has('patch632')
     set ttymouse=sgr
  else
     set ttymouse=xterm2
  endif

  " Paste.
  nnoremap <RightMouse> "+p
  xnoremap <RightMouse> "+p
  inoremap <RightMouse> <C-r><C-o>+
  cnoremap <RightMouse> <C-r>+
endif

" UI
"
set background=dark
" set laststatus=2
" set showtabline=2
set noshowmode

set tags+=.git/tags;/,codex.tags;/
