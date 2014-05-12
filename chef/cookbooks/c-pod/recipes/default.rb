# Default recipe for a complete C-Pod
#
case node[:platform_family]
when 'rhel'
    include_recipe 'yum'
    package 'createrepo'
    package 'yum-utils'
    package 'ruby'
when 'debian'
    include_recipe 'apt'
    package 'createrepo'
    package 'yum-utils'
    package 'ruby-dev'
when 'mac_os_x'
    error "Not supported yet!"
end

node.default['apache']['default_modules'] =  %w[status alias auth_basic authn_file authz_groupfile authz_host authz_user autoindex dir env mime negotiation setenvif]

include_recipe 'apache2::default'

apache_site 'default' do
    enable false
end

web_app 'c-pod' do
    template	'_c-pod.conf.erb'
    enable	true
    base	node[:cpod][:base]
end

include_recipe 'c-pod::user'

cpod_user = node[:cpod][:owner_name]
BASE=node[:cpod][:base]

include_recipe 'c-pod::devtools'

gem_package 'redcarpet'
gem_package 'builder'

include_recipe 'c-pod::repo'

directory "#{BASE}/cookbooks" do
    owner cpod_user
    group cpod_user
    mode 02775
end

git "#{BASE}/cookbooks/sysctl" do
    repository "https://github.com/Youscribe/sysctl-cookbook.git"
    reference "master"
    action :checkout
    group cpod_user
end

git "#{BASE}/cookbooks/ulimit" do
    repository "https://github.com/bmhatfield/chef-ulimit.git"
    reference "master"
    action :checkout
    group cpod_user
end

execute "setup_repo" do
    action :nothing
    command "#{BASE}/c-pod/bin/setup_repo"
end

include_recipe 'c-pod::virt'
include_recipe 'c-pod::socks'
include_recipe 'c-pod::chef-solo'

# vim: sts=4 sw=4 ts=8
