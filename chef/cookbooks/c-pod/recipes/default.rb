# Setting up a C-Pod from the repository
# This default setup creates a Repository host and a KVM host
#
include_recipe 'c-pod::repo_host'
include_recipe 'c-pod::kvm_host'

# vim: sts=4 sw=4 ts=8
