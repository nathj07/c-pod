# Recipe for a C-Pod Repository Host
# This is the future platform-independent one
# Needs much more testing!
#
case node[:platform_family]
when 'rhel'
    include_recipe 'yum'
    package 'createrepo'
    package 'yum-utils'
    package 'bsdtar'
    package 'ruby'
    node.default['apache']['version'] = '2.2'
when 'debian'
    include_recipe 'apt'
    package 'createrepo'
    package 'yum-utils'
    package 'ruby-dev'
    node.default['apache']['version'] = '2.4'
when 'mac_os_x'
    error "Not supported yet!"
end

node.default['apache']['default_modules'] =  %w{
    actions
    alias
    autoindex
    cgi
    dir
    env
    include
    mime
    negotiation
    setenvif
    status
}

node.default['apache']['default_site_enabled'] = false

include_recipe 'apache2::default'

web_app 'c-pod' do
    template	'_c-pod.conf.erb'
    enable	true
    notifies :restart, "service[apache2]", :delayed
end

include_recipe 'c-pod::user'

group cpod_user do
  members node['apache']['user']
  append true
end

cpod_user = node[:cpod][:owner_name]
base=node[:cpod][:base]

include_recipe 'c-pod::devtools'

gem_package 'redcarpet'
gem_package 'builder'

include_recipe 'c-pod::git_repo'
include_recipe 'c-pod::repo_structure'

include_recipe 'c-pod::virt'
include_recipe 'c-pod::socks'
include_recipe 'c-pod::chef-solo'

# vim: sts=4 sw=4 ts=8
