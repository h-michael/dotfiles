" ---------------------------------------------------------------------------
" Search:
"

" Ignore the case of normal letters.
set ignorecase
" If the search pattern contains upper case characters, override ignorecase
" option.
set smartcase

" Enable incremental search.
set incsearch
" Don't highlight search result.
set nohlsearch

" Searches wrap around the end of the file.
set wrapscan


"---------------------------------------------------------------------------
" Edit:
"

" Smart insert tab setting.
set smarttab
" Exchange tab to spaces.
set expandtab
" Substitute <Tab> with blanks.
set tabstop=2
" Spaces instead <Tab>.
set softtabstop=2
" Autoindent width.
set shiftwidth=2
" Round indent by shiftwidth.
set shiftround

" Enable smart indent.
set autoindent smartindent

" Enable modeline.
" set modeline

" Disable modeline.
set modelines=0
set nomodeline

" Use clipboard register.

set clipboard& clipboard+=unnamedplus
if (!has('nvim') || $DISPLAY !=# '') && has('clipboard')
  if has('unnamedplus')
    set clipboard& clipboard+=unnamedplus
  else
    set clipboard& clipboard+=unnamed
  endif
endif

" Enable backspace delete indent and newline.
set backspace=indent,eol,start

" Highlight <>.
set matchpairs+=<:>

" Display another buffer when current buffer isn't saved.
set hidden

" Don't redraw while executing macros (good performance config)
set lazyredraw

" Search home directory path on cd.
" But can't complete.
"  set cdpath+=~

" Enable folding.
" set foldenable
" set foldmethod=expr
" set foldmethod=marker
" Show folding level.
" set foldcolumn=1
set fillchars=vert:\|
set commentstring=%s

" Use vimgrep.
" set grepprg=internal
" Use grep.
set grepprg=grep\ -inH

" Exclude = from isfilename.
set isfname-==

" Keymapping timeout.
set timeout timeoutlen=3000 ttimeoutlen=100

" CursorHold time.
" set updatetime=1000

" Set swap directory.
set directory-=.

" Set undofile.
set undofile
let &g:undodir = &directory

" Enable virtualedit in visual block mode.
set virtualedit=block

" Set keyword help.
set keywordprg=:help

" Check timestamp more for 'autoread'.
autocmd MyAutoCmd WinEnter * checktime

" Disable paste.
autocmd MyAutoCmd InsertLeave *
      \ if &paste | setlocal nopaste | echo 'nopaste' | endif |
      \ if &l:diff | diffupdate | endif

" Update diff.
autocmd MyAutoCmd InsertLeave * if &l:diff | diffupdate | endif

if has('patch-8.1.0360')
  set diffopt=internal,algorithm:patience,indent-heuristic
endif

" Make directory automatically.
" --------------------------------------
" http://vim-users.jp/2011/02/hack202/

autocmd MyAutoCmd BufWritePre *
      \ call MkdirAsNecessary(expand('<afile>:p:h'), v:cmdbang)
function! MkdirAsNecessary(dir, force) abort
  if !isdirectory(a:dir) && &l:buftype ==# '' &&
        \ (a:force || input(printf('"%s" does not exist. Create? [y/N]',
        \              a:dir)) =~? '^y\%[es]$')
    call mkdir(iconv(a:dir, &encoding, &termencoding), 'p')
  endif
endfunction

" Use autofmt.
set formatexpr=autofmt#japanese#formatexpr()

set helplang& helplang=en,ja

" Default home directory.
let t:cwd = getcwd()

" Spell check
set spelllang=en,cjk

set nofixeol

"---------------------------------------------------------------------------
" View:
"

" Show line number.
" set number
" set numberwidth=2
" set relativenumber

" Show <TAB> and <CR>
set list
if IsWindows()
   set listchars=tab:>-,trail:-,extends:>,precedes:<
else
   set listchars=tab:▸\ ,trail:-,extends:»,precedes:«,nbsp:%
endif
" Always display statusline.
set laststatus=2
" Height of command line.
set cmdheight=1
" Not show command on statusline.
" set noshowcmd
" Show title.
set title
" Title length.
set titlelen=95
" Title string.
let &g:titlestring="
      \ %{expand('%:p:~:.')}%(%m%r%w%)
      \ %<\(%{WidthPart(
      \   fnamemodify(getcwd(), ':~'),
      \   &columns-len(expand('%:p:.:~'))
      \ )}\) - VIM"

set showtabline=2

" Turn down a long line appointed in 'breakat'
set linebreak
set showbreak=\
set breakat=\ \	;:,!?

" Wrap conditions.
set whichwrap+=h,l,<,>,[,],b,s,~
if exists('+breakindent')
   set breakindent
   set wrap
else
   set nowrap
endif

" Do not display the greetings message at the time of Vim start.
set shortmess=aTI

" Do not display the completion messages
set noshowmode
if has('patch-7.4.314')
  set shortmess+=c
else
  autocmd MyAutoCmd VimEnter *
        \ highlight ModeMsg guifg=bg guibg=bg |
        \ highlight Question guifg=bg guibg=bg
endif

" Do not display the edit messages
if has('patch-7.4.1570')
  set shortmess+=F
endif

" Don't create backup.
set nowritebackup
set nobackup
set noswapfile
set backupdir-=.

" Disable bell.
set t_vb=
set novisualbell
set belloff=all

set nowildmenu

if exists('&wildoptions')
  " Display candidates by popup menu.
  set wildmenu
  set wildmode=full

  if has('nvim')
    set wildoptions+=pum
  endif
else
  " Display candidate supplement.
  set nowildmenu
  set wildmode=list:longest,full
endif

" Ignore compiled files
set wildignore=*.o,*~,*.pyc
if IsWindows()
  set wildignore+=.git\*,.hg\*,.svn\*
else
  set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
endif

" Increase history amount.
set history=10000
" Display all the information of the tag by the supplement of the Insert mode.
set showfulltag
" Can supplement a tag in a command-line.
set wildoptions+=tagfile

" Completion setting.
set completeopt=menuone
if has('patch-7.4.775')
  set completeopt+=noinsert
endif

" Don't complete from other buffer.
set complete=.

" Set popup menu max height.
set pumheight=20

" Report changes.
set report=0

" Maintain a current line at the time of movement as much as possible.
set nostartofline

" Splitting a window will put the new window below the current one.
set splitbelow

" Splitting a window will put the new window right the current one.
set splitright

" Set minimal width for current window.
set winwidth=30

" Set minimal height for current window.
" set winheight=20
set winheight=1

" Set maximam maximam command line window.
set cmdwinheight=5

" No equal window size.
set noequalalways

" Adjust window size of preview and help.
set previewheight=10

set helpheight=12

set ttyfast

" When a line is long, do not omit it in @.
set display=lastline

" Display an invisible letter with hex format.
"set display+=uhex

function! WidthPart(str, width) abort "{{{
  if a:width <= 0
    return ''
  endif
  let l:ret = a:str
  let l:width = strwidth(a:str)
  while l:width > a:width
    let l:char = matchstr(l:ret, '.$')
    let l:ret = l:ret[: -1 - len(l:char)]
    let l:width -= strwidth(l:char)
  endwhile

  return l:ret
endfunction"}}}

" For conceal.
set conceallevel=2 concealcursor=niv

set colorcolumn=79

let g:netrw_browse_split = 4
