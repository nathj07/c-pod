# A Recipe to setup the OS sysctl parameters
#
sysctl 'vm.overcommit_memory' do
    value '1'
end

sysctl 'vm.overcommit_ratio' do
    value '50'
end

sysctl 'fs.file-max' do
    value '16383'
end

# vim: sts=4 sw=4 ts=8 et
