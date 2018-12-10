let s:save_cpo = &cpoptions
set cpoptions&vim

if exists('b:undo_ftplugin')
  let b:undo_ftplugin .= ' | '
else
  let b:undo_ftplugin = ''
endif
let b:undo_ftplugin .= 'setl modeline<'

" set indent.
setlocal shiftwidth=2 softtabstop=2 tabstop=2

let &cpoptions = s:save_cpo-1

au BufNewFile,BufRead *.jbuilder setf ruby
au BufNewFile,BufRead Guardfile setf ruby
au BufNewFile,BufRead .pryrc setf ruby

" http://pocke.hatenablog.com/entry/2015/09/13/234239
" au FileType ruby setl iskeyword+=?
