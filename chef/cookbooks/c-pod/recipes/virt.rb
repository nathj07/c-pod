# A Recipe to setup KVM virtualization
#

case node[:platform_family]
when 'rhel'
    packages = %w{
	kvm libvirt virt-manager virt-viewer libguestfs-tools
	python-virtinst
	libvirt-python 
    }
    packages.each { |pkg| package pkg }
    service 'libvirtd' do
	supports :restart => true, :reload => true
	action [:enable, :start]
    end

when 'debian'
    packages = %w{ qemu-kvm libvirt-bin apache2 virtinst }
    packages.each { |pkg| package pkg }
    service 'libvirt-bin' do
	supports :restart => true, :reload => true
	action [:enable, :start]
    end

when 'mac_os_x'
    error "This will never likely to be supported!"

end

sysctl 'net.ipv4.ip_forward' do
    value '1'
end

# vim: sts=4 sw=4 ts=8
