" vim-go
" options
let g:go_bin_path = expand('~/.go/bin')
let g:go#use_vimproc = 1
let g:go_asmfmt_autosave = 1
let g:go_auto_type_info = 0
let g:go_autodetect_gopath = 1
let g:go_def_mapping_enabled = 0
let g:go_def_mode = 'godef'
let g:go_doc_command = 'godoc'
let g:go_doc_options = ''
let g:go_fmt_autosave = 1
let g:go_fmt_command = 'goimports'
let g:go_fmt_experimental = 1
let g:go_loclist_height = 15
let g:go_metalinter_enabled = ['vet', 'golint', 'errcheck', 'gotype']
let g:go_snippet_engine = 'ultisnips' " neosnippet
let g:go_template_enabled = 0
let g:go_term_enabled = 1
let g:go_term_height = 30
let g:go_term_width = 30

" highlight
let g:go_highlight_array_whitespace_error = 0    " default : 1
let g:go_highlight_build_constraints = 1
let g:go_highlight_chan_whitespace_error = 0     " default : 1
let g:go_highlight_extra_types = 1
let g:go_highlight_fields = 0                    " default : 0
let g:go_highlight_format_strings = 1
let g:go_highlight_functions = 1                 " default : 0
let g:go_highlight_generate_tags = 1             " default : 0
let g:go_highlight_interfaces = 1                " default : 0
let g:go_highlight_methods = 1                   " default : 0
let g:go_highlight_operators = 1                 " default : 0
let g:go_highlight_space_tab_error = 0           " default : 1
let g:go_highlight_string_spellcheck = 0         " default : 1
let g:go_highlight_structs = 1                   " default : 0
let g:go_highlight_trailing_whitespace_error = 0 " default : 1 highlight
let g:go_highlight_array_whitespace_error = 0    " default : 1
let g:go_highlight_build_constraints = 1
let g:go_highlight_chan_whitespace_error = 0     " default : 1
let g:go_highlight_extra_types = 1
let g:go_highlight_fields = 0                    " default : 0
let g:go_highlight_format_strings = 1
let g:go_highlight_functions = 1                 " default : 0
let g:go_highlight_generate_tags = 1             " default : 0
let g:go_highlight_interfaces = 1                " default : 0
let g:go_highlight_methods = 1                   " default : 0
let g:go_highlight_operators = 1                 " default : 0
let g:go_highlight_space_tab_error = 0           " default : 1
let g:go_highlight_string_spellcheck = 0         " default : 1
let g:go_highlight_structs = 1                   " default : 0
let g:go_highlight_trailing_whitespace_error = 0 " default : 1

" vim-go-stdlib:
let g:go_highlight_error = 1
let g:go_highlight_return = 1
" hi goStdlibErr        gui=Bold    guifg=#ff005f    guibg=None
" hi goString           gui=None    guifg=#92999f    guibg=None
" hi goComment          gui=None    guifg=#787f86    guibg=None
" hi goField            gui=Bold    guifg=#a1cbc5    guibg=None
" hi link               goStdlib          Statement
" hi link               goStdlibReturn    PreProc
" hi link               goImportedPkg     Statement
" hi link               goFormatSpecifier PreProc

" vim-go-stdlib:
let g:go_highlight_error = 1
let g:go_highlight_return = 1
augroup GlobalAutoCmd
  autocmd!
augroup END
command! -nargs=* Gautocmd   autocmd GlobalAutoCmd <args>
command! -nargs=* Gautocmdft autocmd GlobalAutoCmd FileType <args>

Gautocmdft go nmap  <silent><buffer><LocalLeader>]      :<C-u>GoGeneDefinition<CR>
Gautocmdft go nmap  <silent><buffer><C-]>               :<C-u>call GoGuru('definition')<CR>
Gautocmdft go nmap  <silent><buffer><Leader>]           :<C-u>Godef<CR>
Gautocmdft go nmap  <silent><buffer><LocalLeader>db     :<C-u>DlvBreakpoint<CR>
Gautocmdft go nmap  <silent><buffer><LocalLeader>dc     :<C-u>DlvContinue<CR>
Gautocmdft go nmap  <silent><buffer><LocalLeader>dd     :<C-u>DlvDebug<CR>
Gautocmdft go nmap  <silent><buffer><LocalLeader>dn     :<C-u>DlvNext<CR>
Gautocmdft go nmap  <silent><buffer><LocalLeader>dr     :<C-u>DlvBreakpoint<CR>
