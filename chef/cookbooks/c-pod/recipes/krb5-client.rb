# Kerberos 5 Client recipe
#
case node[:platform_family]
when 'rhel'
    package 'heimdal'

when 'debian'
    package 'heimdal-clients'
    package 'heimdal-kcm'
    package 'heimdal-docs'

when 'mac_os_x'
    error "Not required! (Heimdal is built-in)"
end

# vim: sts=4 sw=4 ts=8
