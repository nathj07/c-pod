# Setup root user for installations

# VIM profile

ex /root/.vimrc <<VIMRC
$
a
set nocp
set modeline
set nohlsearch
set statusline=%<%f%h%m%r%=%b\ 0x%B\ \ %l,%c%V\ %P
set laststatus=2
set ts=8 sts=4 sw=4
syntax on
.
x
VIMRC

# Set bash profile

ex /root/.bash_profile <<BASHPROFILE
$
a
set -o vi
.
x
BASHPROFILE

# Add installer ssh key

mkdir /root/.ssh
cat > /root/.ssh/authorized_keys <<SSHKEY
ssh-dss AAAAB3NzaC1kc3MAAACBAK7VinW7LVmseUwi02J8bVdEIq6vF4qw4bx7hB0Nm9sLjQEPsL9NbqZcBbynM29nNgzMLec+16z7nuXRmCRctAOl/fnmSxAxYaRJkdWMUSDh2diiMsBGWybx05efPrZcq4nDCacHdo+RjlsMYas4LIhtVQisfLYXFZ4eJQvrUkobAAAAFQCwA9AYgfuR8mgKT4pQ3bljojXL7QAAAIEAjhaXPMiF8utsJUH3ATHGul1ArjIxmXtgFX/a6EhnakILQ4iS9ptFQbbG05pY5UxoVOIsO/kJ4WA+FnUupS9Enddl9A3V4qtoO2fjzDf/2hoPljTLEa530bO+RZEehhbEZ4PeRXnI8x2wcPboAoXIK4XNiM7S9juzR92GvwhGGQ4AAACAaNYB+afRLP87deR19tAO56tDJmylGyGa3newaEgMMhNdQgqKRoCXAHs5woLlQrZ0TDV9s3MyIz8jWUyLmWCdHG7jMNKBDkSibtuC4eQuKzshIG2hgMhZtV6o8z2vJG5Q59duDzMM/o4d4vNILVDyg2/JOFfSxiSJyIqE44hA7kg= installer@changeme
SSHKEY
chmod 600 /root/.ssh/authorized_keys
