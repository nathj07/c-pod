# Setting up a C-Pod from the repository
# This is one of the three types of C-Pod
#
include_recipe 'c-pod::yum_repo_conf'

yum_package 'httpd'
yum_package 'createrepo'
yum_package 'yum-utils'

include_recipe 'c-pod::devtools'

gem_package 'redcarpet' do # for markdown
    options "--no-rdoc --no-ri"
end
gem_package 'builder'   # for gem building

include_recipe 'c-pod::user'
cpod_user = node[:cpod][:owner_name]
BASE=node[:cpod][:base]

include_recipe 'c-pod::repo'

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

template "/etc/httpd/conf.d/_c-pod.conf" do
    action  :create
    mode    0644
    owner   'apache'
    group   'apache'
    variables( :base => BASE )
    notifies :restart, "service[httpd]", :delayed
end

service 'httpd' do
    supports :restart => true, :reload => true
    action :enable
end

include_recipe 'c-pod::virt'
include_recipe 'c-pod::socks'
include_recipe 'c-pod::chef-solo'

# vim: sts=4 sw=4 ts=8
