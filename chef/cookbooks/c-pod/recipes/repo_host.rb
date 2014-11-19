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
    node.default['apache']['version'] = case osver
                                        when 5...7 then '2.2'
                                        when 7...8 then '2.4'
                                        end
when 'debian'
    include_recipe 'apt'
    package 'createrepo'
    package 'yum-utils'
    package 'ruby-dev'
    node.default['apache']['version'] = '2.4'

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

group node[:cpod][:owner_name] do
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
