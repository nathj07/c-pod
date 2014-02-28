# A Recipe to setup KVM virtualization
#
%w{
    kvm libvirt virt-manager virt-viewer libguestfs-tools
    python-virtinst
    libvirt-python 
}.each {|p| yum_package p}

service 'libvirtd' do
    supports :restart => true, :reload => true
    action [:enable, :start]
end

include_recipe 'sysctl' # This is needed to persist sysctl settings

sysctl_param 'net.ipv4.ip_forward' do
    value 1
end

# vim: sts=4 sw=4 ts=8
