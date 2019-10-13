if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif

let g:airline_theme = 'molokai'

if IsMac()
  let g:airline_powerline_fonts = 0
else
  let g:airline_powerline_fonts = 1
  let g:airline_left_step = ''
  let g:airline_left_alt_sep = ''
  let g:airline_right_sep = ''
  let g:airline_right_alt_sep = ''
  let g:airline_symbols.crypt = ''
  let g:airline_symbols.linenr = '¶'
  let g:airline_symbols.maxlinenr = '㏑'
  let g:airline_symbols.branch = ''
  let g:airline_symbols.paste = 'ρ'
  let g:airline_symbols.spell = 'Ꞩ'
  let g:airline_symbols.notexists = '∄'
  let g:airline_symbols.whitespace = 'Ξ'
  let g:airline_symbols.readonly = ''
endif

function! MyLineNumber()
  return substitute(line('.'), '\d\@<=\(\(\d\{4\}\)\+\)$', ',&', 'g'). ' | '.
    \    substitute(line('$'), '\d\@<=\(\(\d\{4\}\)\+\)$', ',&', 'g')
endfunction

call airline#parts#define('linenr', {'function': 'MyLineNumber', 'accents': 'bold'})
let g:airline_section_z = airline#section#create(['%3p%%: ', 'linenr', ':%4v'])

let g:airline#extensions#branch#enabled = 1
let g:airline_enable_branch = 1
let g:airline#extensions#whitespace#enabled = 1
let g:airline#extensions#ale#enabled = 1
let g:airline#extensions#languageclient#enabled = 1
let g:airline#extensions#csv#enabled = 1
let g:airline#extensions#tabbar#enabled = 1
let g:airline#extensions#promptline#enabled = 0

" let g:airline#extensions#gutentags#enabled = 1

" tabline setting
let g:airline#extensions#tabline#enabled = 1
" let g:airline#extensions#tabline#buffer_idx_mode = 1

function! ALEStatus()
  return ALEGetStatusLine()
endfunction

" set ttimeoutlen=50
