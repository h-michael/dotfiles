" Fast saving
nmap <leader>w :w!<cr>

" :W sudo saves the file 
" (useful for handling the permission-denied error)
command W w !sudo tee % > /dev/null

" Remap VIM 0 to first non-blank character
map 0 ^

" Clear highlight.
function! s:hier_clear()
  if exists(':HierClear')
    HierClear
  endif
endfunction
nnoremap <silent> <Esc><Esc> :<C-u>nohlsearch<CR>:<C-u>call <SID>hier_clear()<CR>
" nnoremap <ESC><ESC> :nohlsearch<CR>:match<CR>

" User yank register
nnoremap PP "0p
" nnoremap p "0p

"---------------------------------------------------------------------------
" Spell checking:
"

" Pressing ,ss will toggle and untoggle spell checking
map <leader>ss :setlocal spell! <CR>

" Shortcuts using <leader>
map <leader>sn ]s
map <leader>sp [s
map <leader>sa zg
map <leader>s? z=

map <C-c>n :cnext<CR>
map <C-c>p :cprevious<CR>
nnoremap <leader>c :cclose<CR>

" yank the word which is under cursor
nnoremap yc vawy

" in insert mode moving key maps
inoremap  <C-e> <END>
inoremap  <C-a> <HOME>

" hjkl with ctrl
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-h> <Left>
inoremap <C-l> <Right>

" move cursor to other window
" by CTRL-hjkl
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <C-h> <C-w>h

" move tab
nnoremap <silent> <C-l> :<C-u>tabnext<CR>
nnoremap <silent> <C-h> :<C-u>tabprevious<CR>

" autocmd MyAutoCmd BufReadPost * delmarks!
" autocmd BufRead *.rs :setlocal tags=./rusty-tags.vi;/,$RUST_SRC_PATH/rusty-tags.vi
" autocmd BufWritePost *.rs :silent! exec "!rusty-tags vi --quiet --start-dir=" . expand('%:p:h') . "&" | redraw!
