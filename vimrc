"Alan's vimrc
"This file won't work well on servers without vim-enhanced

set nocompatible "explicitly get out of vi-compatible mode
set noexrc " don't use local version of .(g)vimrc, .exrc
set bs=2 "set backspace to be able to delete previous characters
set number "show line numbers
"set autochdir "always switch to the current file directory
set wrap! "turn off word wrap
set clipboard+=unnamed "share windows clipboard
set fileformats=unix,dos,mac "support all three, in this order
"set mouse=a "use mouse everywhere
set noerrorbells " don't make noise

"backup files
set backup " make backup files
set backupdir=~/.vim/backup " where to put backup files
set directory=~/.vim/tmp " directory to place swap files in

"Copy options
set cpoptions=aABceFsmq
"             |||||||||
"             ||||||||+-- When joining lines, leave the cursor
"             |||||||      between joined lines
"             |||||||+-- When a new match is created (showmatch)
"             ||||||      pause for .5
"             ||||||+-- Set buffer options when entering the
"             |||||      buffer
"             |||||+-- :write command updates current file name
"             ||||+-- Automatically add <CR> to the last line
"             |||      when using :@r
"             |||+-- Searching continues at the end of the match
"             ||      at the cursor position
"             ||+-- A backslash has no special meaning in mappings
"             |+-- :write updates alternative file name
"             +-- :read updates alternative file name

"Wild auto complete
set wildmenu
set wildmode=list:longest,full

"Turn on smart indent
set smartindent
set ts=2
set noexpandtab
set expandtab "turn tabs into whitespace
set shiftwidth=2 "indent width for autoindent
filetype indent on "indent depends on filetype
nnoremap <F8> :setl noai nocin nosi inde=<CR> "Disable auto indent

"Shortcut to auto indent entire file
nmap <F11> 1G=G
imap <F11> <ESC>1G=Ga

"Turn on incremental search with ignore case (except explicit caps)
set incsearch
set ignorecase
set smartcase

"Informative status line
set statusline=%F%m%r%h%w\ [TYPE=%Y\ %{&ff}]\ [%l/%L\ (%p%%)]
syntax enable

"Enable indent folding
"set foldenable
"set fdm=indent

"Set space to toggle a fold
nnoremap <space> za

"Hide buffer when not in window (to prevent relogin with FTP edit)
set bufhidden=hide

"Have 3 lines of offset (or buffer) when scrolling
set scrolloff=3

"Set the font and size
set guifont=Lucida\ Console"Hide toolbar
set guioptions-=T

"Enable balloon tooltips on spelling suggestions and folds
function! FoldSpellBalloon()
let foldStart = foldclosed(v:beval_lnum )
let foldEnd = foldclosedend(v:beval_lnum)
let lines = []
"Detect if we are in a fold
if foldStart < 0
    " Detect if we are on a misspelled word
    let lines = spellsuggest( spellbadword(v:beval_text)[ 0 ], 5, 0 )
else
    "we are in a fold
    let numLines = foldEnd – foldStart + 1
    "if we have too many lines in fold, show only the first 14
    "and the last 14 lines
    if ( numLines > 31 )
        let lines = getline( foldStart, foldStart + 14 )
        let lines += [ '-- Snipped ' . ( numLines - 30 ) . ' lines --' ]
        let lines += getline( foldEnd – 14, foldEnd )
    else
        "less than 30 lines, lets show all of them
        let lines = getline( foldStart, foldEnd )
    endif
endif
"return result
return join( lines, has( "balloon_multiline" ) ? "\n" : " " )
endfunction

"Set line numbering to take up 5 spaces
set numberwidth=5 "Highlight current line
set cursorline
set showmatch

if has("gui_running")
    colorscheme metacosm
    set mousehide " hide the mouse cursor when typing
    set guioptions=ce
    "              ||
    "              |+-- use simple dialogs rather than pop-ups
    "              +  use GUI tabs, not console style tabs
endif
