let g:lsp_auto_enable = 0
let g:lsp_signs_enabled = 1         " enable signs
let g:lsp_diagnostics_echo_cursor = 1 " enable echo under cursor when in normal mode
let g:lsp_virtual_text_enabled = 0
let g:lsp_log_verbose = 1
let g:lsp_log_file = expand('~/.local/share/nvim/vim-lsp.log')

if executable('gopls')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'gopls',
        \ 'cmd': {server_info->['gopls', '-mode', 'stdio']},
        \ 'whitelist': ['go'],
        \ })
    autocmd BufWritePre *.go LspDocumentFormatSync
endif

if executable('rls')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'rls',
        \ 'cmd': {server_info->['rustup', 'run', 'nightly', 'rls']},
        \ 'workspace_config': {'rust': {'clippy_preference': 'on'}},
        \ 'whitelist': ['rust'],
        \ })
endif

nmap <silent> <Leader>d :LspDefinition<CR>
nmap <silent> <Leader>td :LspTypeDefinition<CR>
nmap <silent> <Leader>h :LspHover<CR>
nmap <silent> <Leader>r :LspReferences<CR>
nmap <silent> <Leader>i :LspImplementation<CR>
nmap <silent> <Leader>sp :split \| :LspDefinition<CR>
nmap <silent> <Leader>vs :vsplit \| :LspDefinition<CR>
nmap <silent> <Leader>st :LspStatus<CR>
nmap <silent> <Leader>pd :LspDocumentDiagnostics<CR>
