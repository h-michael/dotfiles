set hidden
set completefunc=LanguageClient#complete
let g:LanguageClient_diagnosticsEnable = 0
let g:LanguageClient_selectionUI = 'fzf'
let g:LanguageClient_serverCommands = {
    \ 'rust': ['env', 'RUST_LOG=info', 'rustup', 'run', 'nightly', 'rls'],
    \ 'c': ['ccls', '--log-file=/tmp/cc.log'],
    \ 'cpp': ['ccls', '--log-file=/tmp/cc.log'],
    \ 'cuda': ['ccls', '--log-file=/tmp/cc.log'],
    \ 'objc': ['ccls', '--log-file=/tmp/cc.log'],
    \ 'dart': ['dart_language_server'],
    \ 'go': ['gopls'],
    \ 'javascript': ['npx', 'flow', 'lsp'],
    \ 'javascript.jsx': ['npx', 'flow', 'lsp'],
    \ 'typescript': ['typescript-language-server', '--stdio'],
    \ 'haskell': ['hie', '--lsp'],
    \ 'ocaml': ['ocaml-language-server', '--stdio'],
    \ 'python': ['pyls'],
    \ 'Dockerfile': ['docker-langserver', '--stdio'],
    \ }

    " \ 'lua': ['lua-lsp'],
    " \ 'vim': ['vim-language-server', '--stdio']
    " \ 'ruby': ['solargraph', 'stdio'],
    " \ 'rust': ['ra_lsp_server'],
    " \ 'rust': ['env', 'RUST_LOG=info', 'rustup', 'run', 'nightly', 'rls'],
    " \ 'rust': ['env', 'RUST_LOG=info', '/home/h-michael/ghq/github.com/h-michael/rls/target/release/rls'],
    " \ 'rust': ['env', 'RUST_LOG=gen_lsp_server=debug', 'ra_lsp_server'],

let g:LanguageClient_useFloatingHover = 1
let g:LanguageClient_loadSettings = 1 " Use an absolute configuration path if you want system-wide settings
let g:LanguageClient_settingsPath = '~/.config/nvim/settings.json'
let g:LanguageClient_completionPreferTextEdit = 1

" set formatexpr=LanguageClient#textDocument_rangeFormatting_sync()

nnoremap <silent> ;lh   :call LanguageClient_textDocument_hover()<CR>
nnoremap <silent> ;ljd  :call LanguageClient_textDocument_definition()<CR>
nnoremap <silent> ;ljt  :call LanguageClient_textDocument_typeDefinition()<CR>
nnoremap <silent> ;lji  :call LanguageClient_textDocument_implementation()<CR>
nnoremap <silent> <F2>  :call LanguageClient_textDocument_rename()<CR>
nnoremap <silent> ;lr   :call LanguageClient_textDocument_references()<CR>
nnoremap <silent> ;lft  :call LanguageClient_textDocument_formatting()<CR>
nnoremap <silent> ;lftr :call LanguageClient_textDocument_rangeFormatting()<CR>
nnoremap <silent> ;lsy  :call LanguageClient_textDocument_documentSymbol()<CR>
nnoremap <silent> ;lsa  :call LanguageClient_textDocument_codeAction()<CR>

" let g:LanguageClient_loggingLevel='DEBUG'
let g:LanguageClient_loggingLevel = 'INFO'
let g:LanguageClient_loggingFile =  expand('~/.local/share/nvim/LanguageClient.log')
let g:LanguageClient_serverStderr = expand('~/.local/share/nvim/LanguageServer.log')

function! SwitchStableRls() abort
  if (&ft=='rust')
    LanguageClientStop
    ALEStopAllLSPs
    let g:ale_rust_rls_toolchain = 'stable'
    let g:LanguageClient_serverCommands.rust = ['rustup', 'run', 'stable', 'rls']
    sleep 100m
    LanguageClientStart
  endif
endfunction

function! SwitchNightlyRls() abort
  if (&ft=='rust')
    LanguageClientStop
    ALEStopAllLSPs
    let g:ale_rust_rls_toolchain = 'nightly'
    let g:LanguageClient_serverCommands.rust = ['rustup', 'run', 'nightly', 'rls']
    sleep 100m
    LanguageClientStart
  endif
endfunction

command! SwitchStableRls :call SwitchStableRls()
command! SwitchNightlyRls :call SwitchNightlyRls()

function! LspMaybeHover(is_running) abort
  if a:is_running.result && g:LanguageClient_autoHoverAndHighlightStatus
    call LanguageClient_textDocument_hover()
  endif
endfunction

function! LspMaybeHighlight(is_running) abort
  if a:is_running.result && g:LanguageClient_autoHoverAndHighlightStatus
    call LanguageClient#textDocument_documentHighlight()
  endif
endfunction

augroup lsp_aucommands
  au!
  au CursorHold * call LanguageClient#isAlive(function('LspMaybeHover'))
  au CursorMoved * call LanguageClient#isAlive(function('LspMaybeHighlight'))
augroup END

let g:LanguageClient_autoHoverAndHighlightStatus = 0

function! ToggleLspAutoHoverAndHilight() abort
  if g:LanguageClient_autoHoverAndHighlightStatus
    let g:LanguageClient_autoHoverAndHighlightStatus = 0
    call LanguageClient#clearDocumentHighlight()
    echo ""
  else
    let g:LanguageClient_autoHoverAndHighlightStatus = 1
  end
endfunction
nnoremap <silent> ;tg  :call ToggleLspAutoHoverAndHilight()<CR>
function! HandleWindowProgress(params) abort
    echomsg json_encode(a:params)
endfunction
