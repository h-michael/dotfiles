"---------------------------------------------------------------------------
" denite.nvim
"
if executable('rg')
  call denite#custom#var('file/rec', 'command',
    \ ['rg', '--files', '--hidden', '--glob', '!.git'])
  call denite#custom#var('grep', 'command', ['rg', '--threads', '1'])
  call denite#custom#var('grep', 'recursive_opts', [])
  call denite#custom#var('grep', 'final_opts', [])
  call denite#custom#var('grep', 'separator', ['--'])
  call denite#custom#var('grep', 'default_opts', ['--vimgrep', '--no-heading'])
elseif executable('hw')
  call denite#custom#var('file/rec', 'command', ['hw', '--no-color', '--no-group', ''])
elseif executable('ag')
  call denite#custom#var('file/rec', 'command', ['ag', '--follow', '--nocolor', '--nogroup', '-g', ''])
endif

call denite#custom#source('file/mru', 'matchers', ['matcher_cpsm', 'matcher_project_files'])
call denite#custom#source('file/rec,grep', 'matchers', ['matcher_cpsm'])
call denite#custom#source('grep', 'matchers', ['matcher_ignore_globs', 'matcher_cpsm'])
" call denite#custom#source('grep', 'matchers', ['matcher_ignore_globs', 'matcher_cpsm'])
" call denite#custom#var('grep', 'command', ['hw', '--no-color', '--no-group'])
" call denite#custom#var('grep', 'default_opts', [])
" call denite#custom#var('grep', 'recursive_opts', [])
call denite#custom#source('file/old', 'converters', ['converter_relative_word'])

call denite#custom#map('insert', '<C-a>', '<denite:move_caret_to_head>', 'noremap')
call denite#custom#map('insert', '<C-e>', '<denite:move_caret_to_tail>', 'noremap')
call denite#custom#map('insert', '<C-h>', '<denite:move_caret_to_left>', 'noremap')
call denite#custom#map('insert', '<C-l>', '<denite:move_caret_to_right>', 'noremap')
call denite#custom#map('insert', '<C-n>', '<denite:move_to_next_line>', 'noremap')
call denite#custom#map('insert', '<D-H>', '<denite:move_to_top>', 'noremap')
call denite#custom#map('insert', '<D-M>', '<denite:move_to_middle>', 'noremap')
call denite#custom#map('insert', '<D-L>', '<denite:move_to_bottom>', 'noremap')
call denite#custom#map('insert', '<BS>',  '<denite:smart_delete_char_before_caret>', 'noremap')
call denite#custom#map('insert', '<C-h>', '<denite:smart_delete_char_before_caret>', 'noremap')

call denite#custom#alias('source', 'file/rec/git', 'file/rec')
call denite#custom#var('file/rec/git', 'command', ['git', 'ls-files', '-co', '--exclude-standard'])
call denite#custom#option('default', {
      \ 'auto_accel': v:true,
      \ 'prompt': '>',
      \ 'source_names': 'short',
      \ })
      " \ 'post_action': 'suspend',

let s:menus = {}
let s:menus.vim = {
    \ 'description': 'Vim',
    \ }
let s:menus.vim.file_candidates = [
    \ ['    > Edit configuation file (init.vim)', '~/.config/nvim/init.vim']
    \ ]
call denite#custom#var('menu', 'menus', s:menus)

call denite#custom#filter('matcher/ignore_globs', 'ignore_globs',
      \ [
      \ '.git/', '.ropeproject/', '__pycache__/',
      \ 'venv/',
      \ 'images/',
      \ '*.min.*',
      \ 'img/', 'fonts/'])
