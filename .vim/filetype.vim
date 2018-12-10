" My filetype file.

if exists('did_load_filetypes')
  finish
endif

augroup filetypedetect
  " Nemerle
  autocmd BufRead,BufNewfile *.n setf nemerle
  " Perl6
  autocmd BufRead,BufNewfile *.p6 setf perl6
  " Perl5
  autocmd BufRead,BufNewfile *.p5 setf perl
  " TeXEruby
  autocmd BufRead,BufNewFile *.tex.erb setf tex.eruby
  " Haskell
  autocmd BufRead,BufNewFile *.hs setf haskell
  " PureScript
  autocmd BufRead,BufNewFile *.purs setf purescript
  " Flow
  autocmd BufRead,BufNewFile *.flow setf javascript

  " autocmd BufRead,BufNewFile *.slim   set filetype=slim
  " autocmd BufRead,BufNewFile *.haml   set filetype=haml

  " Filetype detect for Assembly Language.
  autocmd BufRead,BufNewFile *.asm set ft=masm syntax=masm
  autocmd BufRead,BufNewFile *.inc set ft=masm syntax=masm
  autocmd BufRead,BufNewFile *.[sS] set ft=gas syntax=gas
  autocmd BufRead,BufNewFile *.hla set ft=hla syntax=hla

  autocmd BufRead,BufNewFile *.fish setf fish

  " Markdown
  autocmd BufRead,BufNewFile *.mkd,*.markdown,*.md,*.mdown,*.mkdn
        \ setlocal filetype=mkd autoindent formatoptions=tcroqn2 comments=n:>
augroup END
