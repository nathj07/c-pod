# A Recipe to setup the Proxy server on a repo
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

# vim: sts=4 sw=4 ts=8
