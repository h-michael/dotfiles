let g:go_gocode_propose_builtins = 1

" https:"github.com/fatih/vim-go/wiki/Tutorial#vimrc-improvements
autocmd FileType go nnoremap <Leader><Leader>b  <Plug>(go-build)
autocmd FileType go nnoremap <Leader>r  <Plug>(go-run)

map <C-n> :cnext<CR>
map <C-m> :cprevious<CR>
nnoremap <leader>a :cclose<CR>

let g:go_list_type = "quickfix"

" https:"github.com/fatih/vim-go/wiki/Tutorial#vimrc-improvements-1
autocmd FileType go nnoremap <leader>t  <Plug>(go-test)

function! s:build_go_files()
  let l:file = expand('%')
  if l:file =~# '^\f\+_test\.go$'
    call go#test#Test(0, 1)
  elseif l:file =~# '^\f\+\.go$'
    call go#cmd#Build(0)
  endif
endfunction

autocmd FileType go nnoremap <Leader><Leader>b :<C-u>call <SID>build_go_files()<CR>

" https:"github.com/fatih/vim-go/wiki/Tutorial#vimrc-improvements-2
autocmd FileType go nnoremap <Leader>c  <Plug>(go-coverage-toggle)

" https://github.com/fatih/vim-go/wiki/Tutorial#beautify-it
let g:go_highlight_types = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_operators = 1
let g:go_highlight_extra_types = 1

" https:"github.com/fatih/vim-go/wiki/Tutorial#vimrc-improvements-3
let g:go_fmt_command = "goimports"

" https:"github.com/fatih/vim-go/wiki/Tutorial#vimrc-improvements-4
autocmd BufNewFile,BufRead *.go setlocal noexpandtab tabstop=4 shiftwidth=4

" https:"github.com/fatih/vim-go/wiki/Tutorial#check-it
"" let g:go_metalinter_enabled = ['vet', 'golint', 'errcheck']
"" let g:go_metalinter_autosave = 1
"" let g:go_metalinter_autosave_enabled = ['vet', 'golint']

" https://github.com/fatih/vim-go/wiki/Tutorial#vimrc-improvements-5
let g:go_def_mode = 'gopls'
let g:go_def_mapping_enabled = 1

autocmd Filetype go command! -bang A  call go#alternate#Switch(<bang>0, 'edit')
autocmd Filetype go command! -bang AV call go#alternate#Switch(<bang>0, 'vsplit')
autocmd Filetype go command! -bang AS call go#alternate#Switch(<bang>0, 'split')
autocmd Filetype go command! -bang AT call go#alternate#Switch(<bang>0, 'tabe')

" https://github.com/fatih/vim-go/wiki/Tutorial#identifier-resolution
autocmd FileType go nnoremap <Leader>h <Plug>(go-info)
" autocmd FileType go nnoremap <Leader>i <Plug>(go-info)
" let g:go_auto_type_info = 1

" https://github.com/fatih/vim-go/wiki/Tutorial#identifier-highlighting
let g:go_auto_sameids = 1
let g:go_doc_popup_window = 1
