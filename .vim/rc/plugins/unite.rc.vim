"---------------------------------------------------------------------------
" unite.vim
"

" let g:ag_working_path_mode="r"
" let g:unite_source_grep_command = 'ag'
" let g:unite_source_grep_default_opts = '--nogroup --nocolor --column'
" let g:unite_source_grep_max_candidates = 200
" let g:unite_source_grep_recursive_opt = ''
if executable('hw')
  let g:unite_source_grep_command = 'hw'
  let g:unite_source_grep_default_opts = '--no-group --no-color'
  let g:unite_source_grep_recursive_opt = ''
endif

" nmap <silent> <C-u><C-f> :<C-u>UniteWithBufferDir -buffer-name=files file<CR>
" nmap <silent> <C-u><C-f> :<C-u>Unite file<CR>
" nnoremap <silent> <C-u><C-b> :<C-u>Unite buffer<CR>
" nnoremap <silent> <C-u><C-g> :<C-u>Unite grep:. -buffer-name=search-buffer<CR>
" nmap <silent> <C-u><C-r> :<C-u>Unite -buffer-name=register register<CR>
" nmap <silent> <C-u><C-m> :<C-u>Unite file_mru<CR>
" nmap <silent> <C-u><C-u> :<C-u>Unite buffer file_mru<CR>
" nmap <silent> <C-u><C-a> :<C-u>UniteWithBufferDir -buffer-name=files buffer file_mru bookmark file<CR>

nnoremap <silent> ,b :<C-u>Unite buffer<CR>
" grep検索
nnoremap <silent> ,g :<C-u>Unite grep:. -buffer-name=search-buffer<CR>
" カーソル位置の単語をgrep検索
nnoremap <silent> ,cg :<C-u>Unite grep:. -buffer-name=search-buffer<CR><C-R><C-W><Paste>
" grep検索結果の再呼出
nnoremap <silent> ,r  :<C-u>UniteResume search-buffer<CR>
" nmap <silent> <C-u><C-r> :<C-u>Unite -buffer-name=register register<CR>
" nmap <silent> <C-u><C-m> :<C-u>Unite file_mru<CR>
" nmap <silent> <C-u><C-u> :<C-u>Unite buffer file_mru<CR>
" nmap <silent> <C-u><C-a> :<C-u>UniteWithBufferDir -buffer-name=files buffer file_mru bookmark file<CR>
" au FileType unite nmap <silent> <buffer> <expr> <C-j> unite#do_action('split')
" au FileType unite imap <silent> <buffer> <expr> <C-j> unite#do_action('split')
au FileType unite nmap <silent> <buffer> <expr> <C-l> unite#do_action('vsplit')
au FileType unite imap <silent> <buffer> <expr> <C-l> unite#do_action('vsplit')
au FileType unite nmap <silent> <buffer> <ESC><ESC> q
au FileType unite imap <silent> <buffer> <ESC><ESC> <ESC>q

let g:unite_enable_ignore_case  = 1
let g:unite_enable_smart_case   = 1
let g:unite_enable_start_insert = 1

" unite-grepの便利キーマップ
" vnoremap /g y:Unite grep::-iRn:<C-R>=escape(@", '\\.*$^[]')<CR><CR>
