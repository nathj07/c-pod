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
include_recipe 'c-pod::git_repo'
include_recipe 'c-pod::repo_structure'

template "/etc/httpd/conf.d/_c-pod.conf" do
    action  :create
    mode    0644
    owner   'apache'
    group   'apache'
    variables( :base => node[:cpod][:base] )
    notifies :restart, "service[httpd]", :delayed
end

service 'httpd' do
    supports :restart => true, :reload => true
    action :enable
end

include_recipe 'c-pod::kvm_host'

include_recipe 'c-pod::chef-solo'

# vim: sts=4 sw=4 ts=8
