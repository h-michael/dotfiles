lua << EOF
  require'nvim_lsp'.clangd.setup{}

  -- https://github.com/golang/tools/blob/master/gopls/doc/settings.md#settings
  require'nvim_lsp'.gopls.setup{
    settings={
      usePlaceholders=true;
      linkTarget="pkg.go.dev";
      completionDocumentation=true;
      completeUnimported=true;
      deepCompletion=true;
      fuzzyMatching=true;
    }
  }

  -- https://github.com/neovim/nvim-lsp#rls
  require'nvim_lsp'.rls.setup{
    settings={
      enableMultiProjectSetup=true;
      all_features=true;
      all_targets=true;
      full_docs=true;
      jobs=2;
      unstable_features=true;
      wait_to_build=1500;
    }
  }

  require'nvim_lsp'.tsserver.setup{}

  -- https://github.com/neovim/nvim-lsp#flow
  require'nvim_lsp'.flow.setup{}

  require'nvim_lsp'.solargraph.setup{}

  vim.lsp.set_log_level("debug")
EOF

autocmd Filetype c          setlocal omnifunc=v:lua.vim.lsp.omnifunc
autocmd Filetype cpp        setlocal omnifunc=v:lua.vim.lsp.omnifunc
autocmd Filetype go         setlocal omnifunc=v:lua.vim.lsp.omnifunc
autocmd Filetype rust       setlocal omnifunc=v:lua.vim.lsp.omnifunc
autocmd Filetype typescript setlocal omnifunc=v:lua.vim.lsp.omnifunc
autocmd Filetype javascript setlocal omnifunc=v:lua.vim.lsp.omnifunc
autocmd Filetype ruby       setlocal omnifunc=v:lua.vim.lsp.omnifunc

nnoremap <silent> gd    <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <silent> <c-]> <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> K     <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> gD    <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> <c-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <silent> 1gD   <cmd>lua vim.lsp.buf.type_definition()<CR>

" function! server_capabilities() abort
" endfunction
" 
" function! get_client_by_name(name) abort
"   v:lua.vim.lsp.get_client_by_name('gopls')
" end
" echo luaeval("vim.inspect(vim.lsp.get_client_by_name('gopls').resolved_capabilities)")
