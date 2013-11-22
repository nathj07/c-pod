" Nick's standard VIM settings
"
set nocompatible
execute pathogen#infect()

filetype plugin indent on
highlight User1 guifg=green guibg=darkslategray term=inverse,bold cterm=bold ctermfg=green ctermbg=black
syntax on

" On a Macbook Air 11 the esc key is tiny so use ;;
map! ;; <Esc>

let mapleader = ","
set listchars=tab:>-,trail:·,eol:$
nmap <silent> <leader>s :set nolist!<CR>

runtime macros/matchit.vim

set laststatus=2
set modelines=5
set sta
set statusline=%<%f%h%m%r%=%1*%{fugitive#statusline()}%*\ %b\ 0x%B\ \ %l,%c%V\ %P
set title
set ts=8 sw=2 sts=2 et
set ve=block
set wildmenu
set wildmode=list:longest
