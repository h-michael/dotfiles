"---------------------------------------------------------------------------
" denite.nvim
"
if executable('rg')
  call denite#custom#var('file/rec', 'command', ['rg', '--files', '--hidden', '--glob', '!.git'])
  call denite#custom#var('grep', 'command', ['rg', '--threads', '2'])
  call denite#custom#var('grep', 'recursive_opts', [])
  call denite#custom#var('grep', 'final_opts', [])
  call denite#custom#var('grep', 'separator', ['--'])
  call denite#custom#var('grep', 'default_opts', ['--vimgrep', '--no-heading'])
elseif executable('ag')
  call denite#custom#var('file/rec', 'command', ['ag', '--follow', '--nocolor', '--nogroup', '-g', ''])
endif

call denite#custom#source('file/mru', 'matchers', ['matcher_cpsm', 'matcher_project_files'])
call denite#custom#source('file/rec', 'grep', 'matchers', ['matcher_cpsm'])
call denite#custom#source('grep', 'matchers', ['matcher_ignore_globs', 'matcher_cpsm'])
call denite#custom#source('file/old', 'converters', ['converter_relative_word'])
call denite#custom#source('mark', 'matchers', ['matcher_cpsm', 'matcher_project_files'])

call denite#custom#map('insert', '<C-a>', '<denite:move_caret_to_head>', 'noremap')
call denite#custom#map('insert', '<C-e>', '<denite:move_caret_to_tail>', 'noremap')
call denite#custom#map('insert', '<C-h>', '<denite:move_caret_to_left>', 'noremap')
call denite#custom#map('insert', '<C-l>', '<denite:move_caret_to_right>', 'noremap')
call denite#custom#map('insert', '<C-n>', '<denite:move_to_next_line>', 'noremap')
call denite#custom#map('insert', '<C-p>', '<denite:move_to_previous_line>', 'noremap')
call denite#custom#map('insert', '<D-H>', '<denite:move_to_top>', 'noremap')
call denite#custom#map('insert', '<D-M>', '<denite:move_to_middle>', 'noremap')
call denite#custom#map('insert', '<D-L>', '<denite:move_to_bottom>', 'noremap')
call denite#custom#map('insert', '<BS>',  '<denite:smart_delete_char_before_caret>', 'noremap')
call denite#custom#map('insert', '<C-h>', '<denite:smart_delete_char_before_caret>', 'noremap')
call denite#custom#map('insert', '<C-T>', '<denite:do_action:tabopen>', 'noremap')

call denite#custom#map('normal', '<C-n>', '<denite:move_to_next_line>', 'noremap')
call denite#custom#map('normal', '<C-p>', '<denite:move_to_previous_line>', 'noremap')

call denite#custom#alias('source', 'file/rec/git', 'file/rec')
call denite#custom#var('file/rec/git', 'command', ['git', 'ls-files', '-co', '--exclude-standard'])
call denite#custom#option('_',
  \    {
  \       'auto_accel': 0,
  \       'auto_preview': 0,
  \       'auto_resume': 1,
  \       'prompt': '>',
  \       'source_names': 'short',
  \       'uniq': 1,
  \       'vertical_preview': 1
  \    }
  \ )
    " \ 'post_action': 'suspend',


call denite#custom#filter('matcher/ignore_globs', 'ignore_globs',
  \ [
  \ '.git/', '.ropeproject/', '__pycache__/',
  \ 'venv/',
  \ 'images/',
  \ '*.min.*',
  \ 'img/', 'fonts/'])
