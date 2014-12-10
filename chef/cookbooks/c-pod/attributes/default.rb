# Default Node Attributes for a C-Pod
#
default[:cpod][:server_name]  = node[:fqdn]
default[:cpod][:repodir]      = '/srv/c-pod'
default[:cpod][:datadir]      = '/srv/cpoddata'
default[:cpod][:owner_name]   = 'c-pod'

# Default Node Attributes for the SOCKS server
# Now knowing which interface is going to be up used to be easy, but
# with CentOS 7 the names are based on hardware and it's complicated
# It thus probably varies with the Virtualization Platform so this file
# should be expanded with the known cases...
#

default[:cpod][:docker][:interface]  = 'docker0'

case node[:platform_family]
when 'rhel'

    case osver
    when 5...7
      default[:cpod][:socks][:public_if]   = 'eth0'
    when 7...8
      default[:cpod][:socks][:public_if]   = 'eno16777736'
    end

when 'debian'
    default[:cpod][:socks][:public_if]   = 'eth0'

when 'mac_os_x'
    error "This will never likely to be supported!"

end

# vim: ft=ruby sts=2 sw=2 ts=8
