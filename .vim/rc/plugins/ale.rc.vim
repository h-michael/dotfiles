" if has('nvim-0.3.2')
"   let g:ale_virtualtext_cursor = 1
"   let g:ale_echo_cursor= 0
"   highlight! link ALEVirtualTextError ErrorMsg
"   highlight! link ALEVirtualTextWarning WarningMsg
" else
"   let g:ale_set_balloons_legacy_echo = 1
"   let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
" endif
let g:ale_set_balloons_legacy_echo = 1
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
" let g:ale_sign_column_always = 1
" let g:ale_sign_error = 'E'
" let g:ale_sign_warning = 'W'
" let g:ale_sign_error = '✖'
" let g:ale_sign_warning = '⚠'
" let g:ale_echo_msg_error_str = 'E'
" let g:ale_echo_msg_warning_str = 'W'

let g:ale_javascript_eslint_executable = g:current_eslint_path
let g:ale_javascript_flow_executable = g:current_flow_path
let g:ale_javascript_prettier_executable = g:current_prettier_path
let g:ale_ruby_rubocop_executable = 'bundle'

let g:ale_linters = {
\   'ruby': ['rubocop'],
\   'rust': ['cargo'],
\   'javascript': ['eslint'],
\   'javascript.jsx': ['eslint'],
\   'jsx': ['eslint'],
\   'haskell': ['hie', '--lsp'],
\}
let g:ale_fixers = {
\   'rust': 'rustfmt',
\   'javascript': 'eslint',
\   'javascript.jsx': 'eslint',
\   'jsx': 'eslint',
\}

nnoremap <silent> ;af :<C-u>ALEFix <CR>

let g:ale_javascript_prettier_use_local_config = 1
let g:ale_rust_cargo_use_clippy = 1
let g:ale_rust_rls_toolchain = 'nightly'
" let g:ale_rust_rls_toolchain = 'stable'

" let g:ale_fix_on_save = 1
" let b:ale_set_balloons = 1
