"---------------------------------------------------------------------------
" deoplete.nvim
"
set completeopt+=noinsert
" <TAB>: completion.
function! s:check_back_space() abort "{{{
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction"}}}
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ deoplete#manual_complete()

" <S-TAB>: completion back.
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> deoplete#smart_close_popup()."\<C-h>"
" inoremap <expr><BS> deoplete#smart_close_popup()."\<C-h>"

inoremap <expr><C-g> deoplete#undo_completion()
" <C-l>: redraw candidates
inoremap <expr><C-l>       deoplete#refresh()

function! s:my_cr_function() abort
  return deoplete#cancel_popup() . "\<CR>"
endfunction
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>

inoremap <expr> ' pumvisible() ? deoplete#close_popup() : "'"

call deoplete#custom#source('_', 'matchers', ['matcher_cpsm'])
" call deoplete#custom#source('_', 'matchers', ['matcher_full_fuzzy'])
" call deoplete#custom#source('_', 'disabled_syntaxes', ['Comment', 'String'])
call deoplete#custom#source('_', 'sorters', [])
call deoplete#custom#source('ghc', 'sorters', ['sorter_word'])

" call deoplete#custom#source('buffer', 'mark', '*')

" Use auto delimiter
call deoplete#custom#source('_', 'converters', [
      \ 'converter_remove_paren',
      \ 'converter_remove_overlap',
      \ 'converter_truncate_abbr',
      \ 'converter_truncate_menu',
      \ 'converter_auto_delimiter',
      \ ])

" call deoplete#custom#option('sources', {
"       \ 'rust': ['omni', 'syntax', 'LanguageClient'],
"       \ 'c': ['buffer', 'tag', 'omni'],
"       \ 'cpp': ['buffer', 'tag', 'omni'],
"       \ 'elm': ['elm', 'member', 'omni', 'tag', 'syntax'],
"       \ })
      " \ 'ruby': ['file', 'omni', 'tag']

call deoplete#custom#source('omni', 'functions', {
      \ 'rust': ['lsp#complete'],
      \ 'elm': ['elm#Complete'],
      \ 'javascript': ['lsp#complete'],
      \ 'javascript.jsx': ['lsp#complete'],
      \})
      " \ 'ruby':  'rubycomplete#Complete',

call deoplete#custom#option('omni_patterns', {
      \ 'elm': '\.',
      \ 'java': '[^. *\t]\.\w*',
      \})

call deoplete#custom#var('omni', 'input_patterns', {
      \ 'elm': '[^ \t]+',
      \ 'ocaml': '[^ ,;\t\[()\]]',
      \ 'java': '[^. *\t]\.\w*',
      \ 'php': '\w+|[^. \t]->\w*|\w+::\w*',
      \ 'clang': '\.\w*|\.->\w*|\w+::\w*',
      \})
      " \ 'elm': ['[^ \t]+'],
      " \ 'ocaml': ['[^ ,;\t\[()\]]', '.*'],
      " \ 'ruby': '[^. *\t]\.\w*',
      " \ 'ruby': ['[^. *\t]\.\w*', '[^. *\t]\.\w*\|\h\w*::', '[a-zA-Z_]\w*::'],

call deoplete#custom#option('keyword_patterns', {
      \ '_': '[a-zA-Z_]\k*\(?',
      \ 'tex': '[^\w|\s][a-zA-Z_]\w*',
      \ })

let g:deoplete#tag#cache_limit_size = 5000000

" inoremap <silent><expr> <C-t> deoplete#mappings#manual_complete('file')

call deoplete#custom#option({
      \ 'auto_complete_delay': 0,
      \ 'camel_case': v:true,
      \ 'smart_case': v:true,
      \ 'refresh_allways': v:true,
      \ 'async_timeout': 100,
      \ 'buffer_path': v:true,
      \ })

" Ignore
" let g:deoplete#ignore_sources.go =
"       \ ['dictionary', 'member', 'omni', 'tag', 'syntax']
" let g:deoplete#ignore_sources.c =
"       \ ['dictionary', 'member', 'omni', 'tag', 'syntax', 'file/include']
" let g:deoplete#ignore_sources.cpp    = g:deoplete#ignore_sources.c
" let g:deoplete#ignore_sources.objc   = g:deoplete#ignore_sources.c
" let g:deoplete#ignore_sources.python =
"       \ ['buffer', 'dictionary', 'member', 'omni', 'tag', 'syntax'] " file/include conflicting deoplete-jedi
" let g:deoplete#ignore_sources.ruby =
"       \ ['omni'] " file/include conflicting deoplete-jedi

" Go
call deoplete#custom#source('go', 'matchers', ['matcher_full_fuzzy'])
call deoplete#custom#source('go', 'sorters', [])
" let g:deoplete#sources#go#auto_goos = 1
" let g:deoplete#sources#go#cgo = 1
" let g:deoplete#sources#go#cgo#libclang_path = '/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/libclang.dylib'
" let g:deoplete#sources#go#cgo#sort_algo = 'alphabetical'
" let g:deoplete#sources#go#gocode_binary = $GOPATH.'/bin/gocode'
" let g:deoplete#sources#go#on_event = 1
" let g:deoplete#sources#go#package_dot = 1
" let g:deoplete#sources#go#pointer = 1
" let g:deoplete#sources#go#sort_class = ['func', 'type', 'var', 'const', 'package']
" let g:deoplete#sources#go#use_cache = 0
" let g:deoplete#sources#go#json_directory = $XDG_CACHE_HOME.'/deoplete/go/darwin_amd64'

" debug:
" call deoplete#enable_logging('DEBUG', $XDG_LOG_HOME.'/nvim/python/deoplete.log')
" call deoplete#custom#option('profile', v:true)
" call deoplete#custom#source('core', 'debug_enabled', 1)
" call deoplete#custom#source('go', 'debug_enabled', 1)
