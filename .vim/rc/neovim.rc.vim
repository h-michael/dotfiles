"---------------------------------------------------------------------------
" For neovim:
"

set inccommand=split

if exists('&pumblend')
  set pumblend=20
endif

" nnoremap <Leader>t    :<C-u>terminal<CR>
" nnoremap !            :<C-u>terminal<Space>
" let PYTHONPATH = expand('$HOME') . '/.pyenv/shims/python3'

let g:ruby_host_prog = expand('$HOME/.rbenv/shims/ruby')

" Skip neovim module check
let g:python_host_skip_check = 1
let g:python3_host_skip_check = 1

" Use cursor shape feature
set guicursor=n-v-c:block-Cursor/lCursor-blinkon0,i-ci:ver25-Cursor/lCursor,r-cr:hor20-Cursor/lCursor

if has('vim_starting') && empty(argv())
  syntax off
endif

" Share the histories
autocmd MyAutoCmd CursorHold * if exists(':rshada') | rshada | wshada | endif
