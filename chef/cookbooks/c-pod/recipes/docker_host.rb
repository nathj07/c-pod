# A Recipe to setup a C-Pod as a Docker host only
# This does not include the Kickstart, YUM and GEM repository functions
# Use recipe 'c-pod::repo_host' for that.
#

include_recipe 'c-pod::docker'
node.default[:cpod][:socks][:private_if] = node[:cpod][:docker][:interface]
include_recipe 'c-pod::socks'

# vim: sts=2 sw=2 ts=8
