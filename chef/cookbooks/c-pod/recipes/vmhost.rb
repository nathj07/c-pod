# A Recipe to setup a C-Pod as a VM host
#
include_recipe 'c-pod::virt'
include_recipe 'c-pod::socks'

yum_package 'avahi'
yum_package 'nss-mdns'

# vim: sts=4 sw=4 ts=8
