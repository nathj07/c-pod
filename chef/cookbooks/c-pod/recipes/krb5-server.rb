# Kerberos 5 Server recipe
# Note that we don't want all the kerberized services, just the KDC
#
case node[:platform_family]
when 'rhel'
    package 'heimdal'

when 'debian'
    package 'heimdal-kdc'

when 'mac_os_x'
    error "Not required! (Use OSX Server)"
end

include_recipe 'krb5-client'

# vim: sts=4 sw=4 ts=8
