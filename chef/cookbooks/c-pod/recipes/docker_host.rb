# A Recipe to setup a C-Pod as a Docker host only
# This does not include the Kickstart, YUM and GEM repository functions
# Use recipe 'c-pod::repo_host' for that.
#

case node[:platform_family]
when 'rhel'
  include_recipe 'yum'
  package 'avahi'
  package 'nss-mdns'

  case osver
  when 5...7
    package 'docker-io'
  when 7...8
    package 'docker'
  end
  cookbook_file '/etc/sysconfig/docker' do
    action  :create
    mode    0755
    owner   'root'
    group   'root'
    notifies :restart, "service[docker]", :delayed
  end

when 'debian'
  include_recipe 'apt'
  package 'docker.io'
  package 'avahi-daemon'
  package 'libnss-mdns'
  cookbook_file '/etc/default/docker' do
    action  :create
    mode    0755
    owner   'root'
    group   'root'
    notifies :restart, "service[docker]", :delayed
  end

when 'mac_os_x'
  error "This will never likely to be supported!"

end

service 'docker' do
  supports :restart => true, :reload => true
  action [:enable, :start]
end

# Docker adds new network interfaces which we need

ohai "getnetifs" do
  action :reload
  plugin "network"
end

sysctl 'net.ipv4.ip_forward' do
  value '1'
end

include_recipe 'c-pod::socks'

# vim: sts=2 sw=2 ts=8
