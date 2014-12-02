# Default Node Attributes for a C-Pod
#
default[:cpod][:server_name]  = node[:fqdn]
default[:cpod][:repodir]      = case node[:platform_family]
                                when 'rhel' then '/data/c-pod'
                                when 'debian' then '/srv/c-pod'
                                else error "Not supported"
                                end
default[:cpod][:datadir]      = File.absolute_path('../cpoddata', node[:cpod][:repodir])
default[:cpod][:owner_name]   = 'c-pod'
