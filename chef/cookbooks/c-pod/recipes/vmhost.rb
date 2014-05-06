# A Recipe to setup a C-Pod as a VM host
#
yum_package 'avahi'
yum_package 'nss-mdns'

include_recipe 'c-pod::virt'
include_recipe 'c-pod::socks'
include_recipe 'c-pod::user'
include_recipe 'c-pod::apache'
include_recipe 'c-pod::repo'

# vim: sts=4 sw=4 ts=8
