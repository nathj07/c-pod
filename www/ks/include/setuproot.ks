# Setup root

# Set VIM profile

ex /root/.vimrc <<VIMRC
$
a
set nocp
set modeline
set nohlsearch
set statusline=%<%f%h%m%r%=%b\ 0x%B\ \ %l,%c%V\ %P
set laststatus=2
set ts=8 sts=4 sw=4
set title
syntax on
.
x
VIMRC

# Edit bash profile

ex /root/.bash_profile <<BASHPROFILE
$
a
set -o vi
.
x
BASHPROFILE

# Don't install RubyGem documentation

ex /etc/gemrc <<GEMRC
$
a
gem: --no-rdoc --no-ri
.
x
GEMRC
