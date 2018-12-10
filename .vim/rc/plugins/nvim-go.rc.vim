" nvim-go
let g:go#highlight#cgo = 1
let g:go#build#autosave = 1
let g:go#build#force = 0
let g:go#fmt#autosave  = 1
let g:go#fmt#mode = 'goimports'
let g:go#guru#keep_cursor = {
      \ 'callees'    : 0,
      \ 'callers'    : 0,
      \ 'callstack'  : 0,
      \ 'definition' : 1,
      \ 'describe'   : 0,
      \ 'freevars'   : 0,
      \ 'implements' : 0,
      \ 'peers'      : 0,
      \ 'pointsto'   : 0,
      \ 'referrers'  : 0,
      \ 'whicherrs'  : 0
      \ }
let g:go#guru#reflection = 0
let g:go#iferr#autosave = 0
let g:go#lint#golint#autosave = 1
let g:go#lint#golint#ignore = ['internal']
let g:go#lint#golint#mode = 'root'
let g:go#lint#govet#autosave = 0
let g:go#lint#govet#flags = ['-v', '-lostcancel']
let g:go#lint#metalinter#autosave = 0
let g:go#lint#metalinter#autosave#tools = ['vet', 'golint']
let g:go#lint#metalinter#deadline = '20s'
let g:go#lint#metalinter#skip_dir = ['internal', 'vendor', 'testdata', '__*.go', '*_test.go']
let g:go#lint#metalinter#tools = ['vet', 'golint']
let g:go#rename#prefill = 1
let g:go#terminal#height = 120
let g:go#terminal#start_insert = 1
let g:go#terminal#width = 120
let g:go#test#args = ['-v']
let g:go#test#autosave = 0
" debug
let g:go#debug = 1
let g:go#debug#pprof = 0

augroup GlobalAutoCmd
  autocmd!
augroup END
command! -nargs=* Gautocmd   autocmd GlobalAutoCmd <args>
command! -nargs=* Gautocmdft autocmd GlobalAutoCmd FileType <args>

" Go
Gautocmdft go nmap  <silent><buffer>K                   <Plug>(go-doc)
" MapLeader Left hand
Gautocmdft go nmap  <silent><buffer><Leader>a           <Plug>(nvim-go-analyze-buffer)
Gautocmdft go nmap  <silent><buffer><Leader>e           <Plug>(nvim-go-rename)
Gautocmdft go nmap  <silent><buffer><Leader>i           <Plug>(nvim-go-iferr)
" MapLeader Right hand
Gautocmdft go nmap  <silent><buffer><LocalLeader>b      <Plug>(nvim-go-build)
Gautocmdft go nmap  <silent><buffer><LocalLeader>gc     <Plug>(nvim-go-callers)
Gautocmdft go nmap  <silent><buffer><LocalLeader>gcs    <Plug>(nvim-go-callstack)
Gautocmdft go nmap  <silent><buffer><LocalLeader>ge     <Plug>(nvim-go-callees)
Gautocmdft go nmap  <silent><buffer><LocalLeader>gi     <Plug>(nvim-go-implements)
Gautocmdft go nmap  <silent><buffer><LocalLeader>gl     <Plug>(nvim-go-metalinter)
Gautocmdft go nmap  <silent><buffer><LocalLeader>gr     <Plug>(nvim-go-referrers)
Gautocmdft go nmap  <silent><buffer><LocalLeader>gs     <Plug>(nvim-go-test-switch)
Gautocmdft go nmap  <silent><buffer><LocalLeader>l      <Plug>(nvim-go-lint)
Gautocmdft go nmap  <silent><buffer><LocalLeader>r      <Plug>(nvim-go-run)
Gautocmdft go nmap  <silent><buffer><LocalLeader>t      <Plug>(nvim-go-test)
Gautocmdft go nmap  <silent><buffer><LocalLeader>v      <Plug>(nvim-go-vet)
