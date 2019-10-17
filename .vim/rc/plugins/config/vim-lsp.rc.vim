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

    autocmd FileType clangd setlocal omnifunc=lsp#complete
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
    autocmd FileType go setlocal omnifunc=lsp#complete
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
    autocmd FileType rust setlocal omnifunc=lsp#complete
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
    autocmd FileType lua setlocal omnifunc=lsp#complete
  augroup END
endif

if executable('pyls')
  augroup LspPython
    autocmd!
    autocmd User lsp_setup call lsp#register_server({
        \ 'name': 'pyls',
        \ 'cmd': {server_info->['pyls']},
        \ 'whitelist': ['python'],
        \ })
    autocmd FileType python setlocal omnifunc=lsp#complete
  augroup END
endif

if executable(nrun#Which('flow'))
  augroup LspFlow
    autocmd!
    autocmd User lsp_setup call lsp#register_server({
        \ 'name': 'flow',
        \ 'cmd': {server_info->[nrun#Which('flow'), 'lsp']},
        \ 'whitelist': ['javascript', 'javascript.jsx'],
        \ })
    autocmd FileType javascript,javascript.jsx setlocal omnifunc=lsp#complete
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
