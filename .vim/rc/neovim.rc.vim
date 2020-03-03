"---------------------------------------------------------------------------
" For neovim:
"

set inccommand=split

if exists('&pumblend')
  set pumblend=20
endif

let g:loaded_ruby_provider = 0
" let g:ruby_host_prog = expand('$HOME/.anyenv/envs/rbenv/shims/ruby')

let g:loaded_python_provider = 0
let g:loaded_python3_provider = 0

let g:loaded_node_provider = 0

" Use cursor shape feature
set guicursor=n-v-c:block-Cursor/lCursor-blinkon0,i-ci:ver25-Cursor/lCursor,r-cr:hor20-Cursor/lCursor

if has('vim_starting') && empty(argv())
  syntax off
endif

" Share the histories
let &shadafile = expand('$XDG_DATA_HOME/nvim/shada/main.shada')
autocmd MyAutoCmd CursorHold * if exists(':rshada') | rshada | wshada | endif

lua require"vim_extension"
