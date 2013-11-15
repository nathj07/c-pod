" Nick's simple VIM settings
"
set nocompatible
set modeline
set modelines=5
set wildmenu
set wildmode=list:longest
set title
set nohlsearch
set statusline=%<%f%h%m%r%=%b\ 0x%B\ \ %l,%c%V\ %P
set laststatus=2
set ts=8 sts=4 sw=4
syntax on
filetype plugin on
filetype indent on
runtime macros/matchit.vim

let mapleader = ","
set listchars=tab:>-,trail:·,eol:$
nmap <silent> <leader>s :set nolist!<CR>
