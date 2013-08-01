# Add Nick Townsend as the installation user (Note that the user kickstart option is useless as you can't specify gid!)

groupadd -g 625 ntownsend
useradd -c "Nick Townsend" -g 625 -u 625 -p '$1$ZjqgZlNs$mIqvBcMq6kcUCDsLjyH3I0' ntownsend

# Add home mount entry for VMware tools

mkdir /home/ntownsend/host

ex /etc/fstab <<FSTAB
$
a
.host:/ntownsend       /home/ntownsend/host     vmhgfs  rw,uid=625,gid=625
.
x
FSTAB

# Set my VIM profile

ex /home/ntownsend/.vimrc <<VIMRC
$
a
" Nick's VIM settings
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
.
x
VIMRC

# Set my bash profile

ex /home/ntownsend/.bash_profile <<BASHPROFILE
$
a
set -o vi
.
x
BASHPROFILE

# Edit sudo file - note it's RO so need x!

ex /etc/sudoers <<SUDOERS
$
a
ntownsend ALL=(ALL) NOPASSWD: ALL
.
x!
SUDOERS

# Add gitconfig
cat > /home/ntownsend/.gitconfig <<GITCONFIG
[user]
        name = Nick Townsend
        email = nick.townsend@mac.com
[color]
        ui = true
[push]
	default = tracking
GITCONFIG

# Add my ssh key

mkdir /root/.ssh
cat > /root/.ssh/authorized_keys <<SSHKEY
ssh-dss AAAAB3NzaC1kc3MAAACBAPdxDg22fWp3xwJgeUhHLThqkaKQoBZwbdcuAqEWER3ruDpgvQxJ6cCK/xnp2BonpOUOM0RUaIfXF40w5GwOsuVeljJL/2Gcoih1+wLiBixv4ApRjvv9WSSXboak99/jE5MMPJISgO/5peYOR3+h2NAoPP4CvLAD2pNNKxGT6gzrAAAAFQCqg4dG4If2bEdkJJcu9gmfFFCJFwAAAIBqy+F1O/ffcfyVWGU+lJDDTkG3DjRDuus6UBqgaVAGPqUb5si5gZny22/cZX0u0vE7iHcd5AatHIc75UMC1dCBylh6YllOlBk74MGv1aj7gTkW+IJ/ieZbjq8MfoJEgAcKiGuUKgp/ymYj8Oj8bsE9UgJWmSNTfpORkAtgd2bDpwAAAIEAtKIw95NpIn0NY1oHu+P4NaBM6yzENPiVXU2JXXLi4MU0s/q9Eq85/N9v28bGhQOky3gJkhXLlPkPwPBvsdvT3nr/FHyzAQ7E0wIc9ODdgisLbVKXJO2Lt0WkQI2pounXtBEO5NHB4ER1aPNZ6p72TkoUmG8A6UJ8Pu6boCQ4i78= nick_townsend@cube
SSHKEY
chmod 600 /root/.ssh/authorized_keys

mkdir /home/ntownsend/.ssh
cp /root/.ssh/authorized_keys /home/ntownsend/.ssh/authorized_keys
chmod 750 /home/ntownsend/.ssh
chmod 600 /home/ntownsend/.ssh/authorized_keys

# Set ownership

chown -R ntownsend.ntownsend /home/ntownsend/{host,.bash*,.vimrc,.ssh,.gitconfig}
