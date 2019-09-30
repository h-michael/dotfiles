
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

function! s:my_cr_function() abort
  return pumvisible() ? deoplete#close_popup()."\<CR>" : "\<CR>"
endfunction

" <S-TAB>: completion back.
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> deoplete#smart_close_popup()."\<C-h>"
" inoremap <expr><BS> deoplete#smart_close_popup()."\<C-h>"

inoremap <expr><C-g> deoplete#undo_completion()
" <C-l>: redraw candidates
inoremap <expr><C-l> deoplete#manual_complete()

inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>

inoremap <expr> ' pumvisible() ? deoplete#close_popup() : "'"

" call deoplete#custom#source('_', 'matchers', ['matcher_cpsm'])
" call deoplete#custom#source('_', 'matchers', ['matcher_full_fuzzy'])
" call deoplete#custom#source('_', 'disabled_syntaxes', ['Comment', 'String'])
call deoplete#custom#source('_', 'min_pattern_length', 1)

call deoplete#custom#source('_', 'sorters', [])
call deoplete#custom#source('ghc', 'sorters', ['sorter_word'])

" call deoplete#custom#source('buffer', 'mark', '*')

" Use auto delimiter
call deoplete#custom#source('_', 'converters', [
      \ 'converter_remove_paren',
      \ 'converter_remove_overlap',
      \ 'converter_truncate_abbr',
      \ 'converter_truncate_menu',
      \ 'converter_truncate_info',
      \ 'converter_auto_delimiter',
      \ 'matcher_length'
      \ ])

call deoplete#custom#source('LanguageClient', 'min_pattern_length', 1)

call deoplete#custom#option('sources', {
      \ '_': ['omni', 'buffer', 'directory', 'file', 'syntax','LanguageClient', 'syntax', 'lsp'],
      \ })

" call deoplete#custom#source('tabnine', 'rank', 300)
" call deoplete#custom#source('tabnine', 'min_pattern_length', 2)
" call deoplete#custom#source('tabnine', 'is_volatile', v:false)
" call deoplete#custom#source('tabnine', 'converters', [
"       \ 'converter_remove_overlap',
"       \ ])

" call deoplete#custom#option('omni_patterns', {
"       \ 'elm': '\.',
"       \ 'java': '[^. *\t]\.\w*',
"       \})

" call deoplete#custom#var('omni', 'input_patterns', {
"       \ 'elm': '[^ \t]+',
"       \ 'ocaml': '[^ ,;\t\[()\]]',
"       \ 'java': '[^. *\t]\.\w*',
"       \ 'php': '\w+|[^. \t]->\w*|\w+::\w*',
"       \ 'clang': '\.\w*|\.->\w*|\w+::\w*',
"       \})
"       \ 'elm': ['[^ \t]+'],
"       \ 'ocaml': ['[^ ,;\t\[()\]]', '.*'],
"       \ 'ruby': '[^. *\t]\.\w*',
"       \ 'ruby': ['[^. *\t]\.\w*', '[^. *\t]\.\w*\|\h\w*::', '[a-zA-Z_]\w*::'],
"

call deoplete#custom#option('keyword_patterns', {
      \ '_': '[a-zA-Z_]\k*\(?',
      \ 'tex': '[^\w|\s][a-zA-Z_]\w*',
      \ })

let g:deoplete#tag#cache_limit_size = 5000000

" inoremap <silent><expr> <C-t> deoplete#mappings#manual_complete('file')

call deoplete#custom#option({
      \ 'auto_complete_delay': 10,
      \ 'camel_case': v:true,
      \ 'smart_case': v:true,
      \ 'async_timeout': 100,
      \ 'buffer_path': v:true,
      \ 'skip_multibyte': v:true,
      \ 'prev_completion_mode': 'length',
      \ 'auto_preview': v:true,
      \ })
      " \ 'refresh_allways': v:true,

" Ignore

" call deoplete#custom#option('ignore_sources',
"       \ {'_': ['around', 'buffer', 'tag', 'dictionary']})
" let g:deoplete#ignore_sources.c =
"       \ ['dictionary', 'member', 'omni', 'tag', 'syntax', 'file/include']
" let g:deoplete#ignore_sources.cpp    = g:deoplete#ignore_sources.c
" let g:deoplete#ignore_sources.objc   = g:deoplete#ignore_sources.c
" let g:deoplete#ignore_sources.python =
"       \ ['buffer', 'dictionary', 'member', 'omni', 'tag', 'syntax'] " file/include conflicting deoplete-jedi
" let g:deoplete#ignore_sources.ruby =
"       \ ['omni'] " file/include conflicting deoplete-jedi

" debug:
" call deoplete#enable_logging('DEBUG', $HOME.'/.local/share/nvim/deoplete.log')
" call deoplete#custom#option('profile', v:true)
" call deoplete#custom#source('core', 'debug_enabled', 1)

let g:necosyntax#min_keyword_length = 2
