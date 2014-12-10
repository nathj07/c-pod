# A Recipe to setup Docker from binaries
# Based on: https://docs.docker.com/installation/binaries/
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
    package 'iptables'
    package 'xz'
    package 'procps'
    package 'git'

    # To own the Unix socket
    #
    group 'docker' do
      system  true
    end

    # https://raw.githubusercontent.com/tianon/cgroupfs-mount/master/cgroupfs-mount
    #
    remote_file '/usr/bin/docker' do
      source "https://get.docker.com/builds/Linux/x86_64/docker-1.3.2"
      mode    0755
      owner   'root'
      group   'root'
    end
    cookbook_file '/lib/systemd/system/docker.service' do
      action  :create
      mode    0644
      owner   'root'
      group   'root'
      notifies :restart, "service[docker]", :delayed
    end
    cookbook_file '/lib/systemd/system/docker.socket' do
      action  :create
      mode    0644
      owner   'root'
      group   'root'
      notifies :restart, "service[docker]", :delayed
    end
  end
  cookbook_file '/etc/sysconfig/docker' do
    source  'docker.defaults'
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
  error "This will never likely be supported!"

end

service 'NetworkManager' do
  action [:disable, :stop]
end

service 'docker' do
  supports :restart => true, :reload => true
  action [:enable, :start]
end

# vim: sts=2 sw=2 ts=8
