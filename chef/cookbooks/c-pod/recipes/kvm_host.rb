# A Recipe to setup a C-Pod as a VM host only
#
yum_package 'avahi'
yum_package 'nss-mdns'

include_recipe 'c-pod::user'
include_recipe 'c-pod::repo'
include_recipe 'c-pod::virt'

# virt packages add new network interfaces which we need
ohai "getnetifs" do
    action :reload
    plugin "network"
end

include_recipe 'c-pod::socks'

# vim: sts=4 sw=4 ts=8
