# A Recipe to setup the OS sysctl parameters
#
sysctl_param 'vm.overcommit_memory' do
    value 1
end

sysctl_param 'vm.overcommit_ratio' do
    value 50
end

sysctl_param 'fs.file-max' do
    value 16383
end

include_recipe 'sysctl' # This is needed to persist the above

# vim: sts=4 sw=4 ts=8 et
