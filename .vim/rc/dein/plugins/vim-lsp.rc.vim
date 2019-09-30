let g:lsp_auto_enable = 1
let g:lsp_signs_enabled = 1         " enable signs
let g:lsp_diagnostics_echo_cursor = 1 " enable echo under cursor when in normal mode
let g:lsp_virtual_text_enabled = 0
let g:lsp_log_verbose = 1
let g:lsp_log_file = expand('~/.local/share/nvim/vim-lsp.log')

if executable('clangd')
  augroup LspClangd
    autocmd!
    autocmd User lsp_setup call lsp#register_server({
        \ 'name': 'clangd',
        \ 'cmd': {server_info->['clangd', '-background-index']},
        \ 'whitelist': ['c', 'cpp', 'objc', 'objcpp'],
        \ })
  augroup END
endif

if executable('gopls')
  augroup LspGopls
    autocmd!
    autocmd User lsp_setup call lsp#register_server({
        \ 'name': 'gopls',
        \ 'cmd': {server_info->['gopls', '-mode', 'stdio']},
        \ 'whitelist': ['go'],
        \ })
    autocmd BufWritePre *.go LspDocumentFormatSync
  augroup END
endif

if executable('rls')
  augroup LspRust
    autocmd!
    autocmd User lsp_setup call lsp#register_server({
        \ 'name': 'rls',
        \ 'cmd': {server_info->['rustup', 'run', 'nightly', 'rls']},
        \ 'workspace_config': {'rust': {'clippy_preference': 'on'}},
        \ 'whitelist': ['rust'],
        \ })
  augroup END
endif

if executable('lua-lsp')
  augroup LspLua
    autocmd!
    autocmd User lsp_setup call lsp#register_server({
        \ 'name': 'lua-lsp',
        \ 'cmd': {server_info->['lua-lsp']},
        \ 'whitelist': ['lua'],
        \ })
  augroup END
endif

if executable('npx')
  augroup LspFlow
    autocmd!
    autocmd User lsp_setup call lsp#register_server({
        \ 'name': 'flow',
        \ 'cmd': {server_info->['npx', 'flow', 'lsp']},
        \ 'whitelist': ['javascript', 'javascript.jsx'],
        \ })
  augroup END
endif

nnoremap <silent> ;ljd :LspDefinition<CR>
nnoremap <silent> ;ljt :LspTypeDefinition<CR>
nnoremap <silent> ;lji :LspImplementation<CR>
nnoremap <silent> ;lh  :LspHover<CR>
nnoremap <silent> ;lr  :LspReferences<CR>
nnoremap <silent> ;lsd :split \| :LspDefinition<CR>
nnoremap <silent> ;lvd :vsplit \| :LspDefinition<CR>
nnoremap <silent> ;lst :LspStatus<CR>
nnoremap <silent> ;ld  :LspDocumentDiagnostics<CR>
