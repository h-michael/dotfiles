vim = vim
local opt = vim.opt
local api = vim.api

opt.compatible = false

opt.ignorecase = true
-- If the search pattern contains upper case characters, override ignorecase
-- option.
opt.smartcase = true

-- Enable incremental search.
opt.incsearch = true
-- Don't highlight search result.
opt.hlsearch = false

-- Searches wrap around the end of the file.
opt.wrapscan = true

-- Smart insert tab setting.
opt.smarttab = true
-- Exchange tab to spaces.
opt.expandtab = true
-- Substitute <Tab> with blanks.
opt.tabstop = 2
-- Spaces instead <Tab>.
opt.softtabstop = 2
-- Autoindent width.
opt.shiftwidth = 2
-- Round indent by shiftwidth.
opt.shiftround = true

-- Enable smart indent.
opt.autoindent = true
opt.smartindent = true

-- Enable modeline.
-- set modeline

-- Disable modeline.
opt.modelines = 0
opt.modeline = true

-- Use clipboard register.
opt.clipboard:append({'unnamedplus'})

-- Enable backspace delete indent and newline.
opt.backspace = { 'indent', 'eol', 'start' }

-- Highlight <>.
opt.matchpairs:append('<:>')

-- Display another buffer when current buffer isn't saved.
opt.hidden = true

-- Don't redraw while executing macros (good performance config)
opt.lazyredraw = true

-- Search home directory path on cd.
-- But can't complete.
--  set cdpath+=~

-- Enable folding.
-- opt.foldenable = true
-- opt.foldmethod = 'expr'
-- opt.foldmethod = 'marker'
-- Show folding level.
opt.foldcolumn = '1'
--opt.fillchars = { vert: '|' }
opt.commentstring = '%s'

-- Use vimgrep.
-- set grepprg=internal
-- Use grep.
opt.grepprg = 'grep -inH'

-- Exclude = from isfilename.
opt.isfname:remove('=')

-- Keymapping timeout.
--opt.timeout timeoutlen=3000 = ttimeoutlen=100

-- CursorHold time.
-- set updatetime=1000

-- opt.swap = directory.
opt.directory:remove('.')

-- Set undofile.
opt.undofile = true
api.nvim_set_var('undodir', opt.directory)

-- Enable virtualedit in visual block mode.
opt.virtualedit = 'block'

-- opt.keyword = help.
opt.keywordprg = ':help'

-- Disable paste.
--autocmd MyAutoCmd InsertLeave *
--      \ if &paste | setlocal nopaste | echo 'nopaste' | endif |
--      \ if &l:diff | diffupdate | endif

-- Update diff.
--autocmd MyAutoCmd InsertLeave * if &l:diff | diffupdate | endif
opt.diffopt = 'internal,algorithm:patience,indent-heuristic'

-- Use autofmt.
--opt.formatexpr = autofmt#japanese#formatexpr()

opt.helplang = { 'en', 'ja' }

-- Default home directory.
vim.t.cwd = vim.fn.getcwd()

-- Spell check
opt.spelllang = { 'en', 'cjk' }

--opt.nofixeol = true

-----------------------------------------------------------------------------
-- View:
--

-- Show line number.
-- set number
-- set numberwidth=2
-- set relativenumber

-- Show <TAB> and <CR>
opt.list = true
opt.listchars = { tab = '▸\\ ', trail = '-', extends = '»', precedes = '«', nbsp = '%' }
-- Always display statusline.
opt.laststatus = 2
-- Height of command line.
opt.cmdheight = 1
-- Not show command on statusline.
-- set noshowcmd
-- Show title.
opt.title = true
-- Title length.
opt.titlelen = 95

opt.showtabline = 2

-- Turn down a long line appointed in 'breakat'
opt.linebreak = true
opt.showbreak = '\\'
opt.breakat = '\\	;:,!?'

-- Wrap conditions.
opt.whichwrap = 'h,l,<,>,[,],~'
opt.breakindent = true
opt.wrap = true

-- Do not display the greetings message at the time of Vim start.
opt.shortmess = 'aTI'

-- Do not display the completion messages
--opt.noshowmode = true
opt.shortmess = 'c'

-- Do not display the edit messages
opt.shortmess = 'F'

-- Don't create backup.
opt.writebackup = false
opt.backup = false
opt.swapfile = false
opt.backupdir:remove('.')

-- Disable bell.
--opt.t_vb = false
opt.visualbell = false
opt.belloff = 'all'

opt.wildmenu = true
opt.wildmode = 'full'
opt.wildoptions = 'pum'

-- Ignore compiled files
opt.wildignore = { '*.o', '*~', '*.pyc', '*/.git/*', '*/.hg/*', '*/.svn/*', '*/.DS_Store' }

-- Increase history amount.
opt.history = 10000
-- Display all the information of the tag by the supplement of the Insert mode.
opt.showfulltag = true
-- Can supplement a tag in a command-line.
opt.wildoptions:append('tagfile')

-- Completion setting.
opt.completeopt = 'menuone'
opt.completeopt:append('noinsert')

-- Don't complete from other buffer.
opt.complete = '.'

-- opt.popup menu max = height.
opt.pumheight = 20

opt.pumblend = 20

-- Report changes.
opt.report = 0

-- Maintain a current line at the time of movement as much as possible.
opt.startofline = false

-- Splitting a window will put the new window below the current one.
opt.splitbelow = true

-- Splitting a window will put the new window right the current one.
opt.splitright = true

-- opt.minimal width for current = window.
opt.winwidth = 30

-- opt.minimal height for current = window.
-- set winheight=20
opt.winheight = 1

-- opt.maximam maximam command line = window.
opt.cmdwinheight = 5

-- No equal window size.
opt.equalalways = false

-- Adjust window size of preview and help.
opt.previewheight = 10

opt.helpheight = 12

opt.ttyfast = true

-- When a line is long, do not omit it in @.
opt.display = 'lastline'

-- Display an invisible letter with hex format.
--set display+=uhex

-- For conceal.
opt.conceallevel = 2
opt.concealcursor = 'niv'

opt.colorcolumn = '79'

api.nvim_set_var('netrw_browse_split', 4)

opt.termguicolors = true
--let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
--let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

opt.showmode = false
opt.tags:append('.git/tags;', 'codex.tags;')

opt.inccommand = 'split'

api.nvim_set_var('loaded_python_provider', false)
api.nvim_set_var('loaded_python3_provider', false)
api.nvim_set_var('loaded_node_provider', false)
api.nvim_set_var('loaded_ruby_provider', false)
api.nvim_set_var('loaded_ruby_provider', false)
