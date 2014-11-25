# Recipe for a C-Pod Repository Host
# This does not include the KVM virtualization component and SOCKS proxy
# Use the recipe c-pod::kvm_host for that
#

case node[:platform_family]
when 'rhel'
    include_recipe 'yum'
    package 'createrepo'
    package 'yum-utils'
    package 'bsdtar'
    package 'ruby'
    package 'ruby-devel'
    case osver
    when 5...7
        node.default['apache']['version'] = '2.2'
        package 'avahi-daemon'
    when 7...8 
        node.default['apache']['version'] = '2.4'
        package 'avahi'
    end

when 'debian'
    include_recipe 'apt'
    package 'avahi-daemon'
    package 'createrepo'
    package 'yum-utils'
    case osver
    when 10...14
        node.default['apache']['version'] = '2.2'
        package 'ruby1.9.3'
        package 'ruby1.9.1-dev'
    else
        node.default['apache']['version'] = '2.4'
        package 'ruby1.9.3'
        package 'ruby1.9.1-dev'
    end

when 'mac_os_x'
    error "Not supported yet!"
end

node.default['apache']['default_modules']  +=  %w{
    actions
    cgi
    include
}

node.default['apache']['default_site_enabled'] = false

include_recipe 'apache2::default'

web_app 'c-pod' do
    template	'_c-pod.conf.erb'
    enable	true
    notifies :restart, "service[apache2]", :delayed
end

include_recipe 'c-pod::user'

resources(:group => node[:cpod][:owner_name]) do
  members node['apache']['user']
  append true
end

include_recipe 'c-pod::devtools'

gem_package 'redcarpet'
gem_package 'builder'

include_recipe 'c-pod::git_repo'
include_recipe 'c-pod::repo_structure'
include_recipe 'c-pod::chef-solo'

# vim: sts=4 sw=4 ts=8
