"---------------------------------------------------------------------------
" For neovim:
"

set inccommand=split

" tnoremap   <ESC>      <C-\><C-n>
" tnoremap   jj         <C-\><C-n>
" tnoremap   j<Space>   j
" tnoremap <expr> ;  vimrc#sticky_func()
" inoremap <expr> ;  vimrc#sticky_func()
" cnoremap <expr> ;  vimrc#sticky_func()
" snoremap <expr> ;  vimrc#sticky_func()

nnoremap <Leader>t    :<C-u>terminal<CR>
nnoremap !            :<C-u>terminal<Space>
" let PYTHONPATH = expand('$HOME') . '/.pyenv/shims/python3'

if IsMac()
  " let g:python_host_prog = '/usr/local/bin/python2'
  let g:python3_host_prog = '/usr/local/bin/python3'
else
  " let g:python_host_prog = '/usr/bin/python2'
  let g:python3_host_prog = '/usr/bin/python3'
endif

let g:ruby_host_prog = expand('$HOME/.rbenv/shims/ruby')

" Skip neovim module check
let g:python_host_skip_check = 1
let g:python3_host_skip_check = 1

" Set terminal colors
" let s:num = 0
" for s:color in [
"       \ '#6c6c6c', '#ff6666', '#66ff66', '#ffd30a',
"       \ '#1e95fd', '#ff13ff', '#1bc8c8', '#c0c0c0',
"       \ '#383838', '#ff4444', '#44ff44', '#ffb30a',
"       \ '#6699ff', '#f820ff', '#4ae2e2', '#ffffff',
"       \ ]
"   let g:terminal_color_{s:num} = s:color
"   let s:num += 1
" endfor

" Use cursor shape feature
set guicursor=n-v-c:block-Cursor/lCursor-blinkon0,i-ci:ver25-Cursor/lCursor,r-cr:hor20-Cursor/lCursor

if has('vim_starting') && empty(argv())
  syntax off
endif

" Share the histories
autocmd MyAutoCmd CursorHold * if exists(':rshada') | rshada | wshada | endif
