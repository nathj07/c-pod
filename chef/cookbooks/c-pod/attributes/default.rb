# Default Node Attributes for a C-Pod
#
default[:cpod][:server_name]  = node[:fqdn]
default[:cpod][:repodir]      = '/srv/c-pod'
default[:cpod][:datadir]      = '/srv/cpoddata'
default[:cpod][:owner_name]   = 'c-pod'
