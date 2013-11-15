[ -f /etc/profile ] && source /etc/profile
[ -f /etc/bashrc ] && source /etc/bashrc
export PGDATA=/var/lib/pgsql/9.2/data
export PATH=/usr/pgsql-9.2/bin:$PATH
set -o vi
