# Setting up a C-Pod from the repository
# Note use of setgid and apache group to allow sharing
# Together with umask 0002
#
yum_package 'httpd'
yum_package 'createrepo'

include_recipe 'c-pod::devtools'

gem_package 'redcarpet' do # for markdown
    options "--no-rdoc --no-ri"
end
gem_package 'builder'   # for gem building

CPOD = 'c-pod'.to_sym

node.default[CPOD][:base] = '/data'
node.default[CPOD][:owner_name] = 'packager'
node.default[CPOD][:owner_id] = 505

BASE=node[CPOD][:base]

group node[CPOD][:owner_name] do
  action :create
  gid node[CPOD][:owner_id]
end

user node[CPOD][:owner_name] do
  action    :create
  comment   "C-Pod owner"
  home	    BASE
  gid node[CPOD][:owner_id]
  uid node[CPOD][:owner_id]
  supports :manage_home => false
end

group 'apache' do
  action    :modify
  members   node[CPOD][:owner_name]
  append    true
end

directory BASE do
    owner node[CPOD][:owner_name]
    group node[CPOD][:owner_name]
    mode 02755		# need setgid so that all are apache group
end

cookbook_file "#{BASE}/README" do
    source  'README.data'
    mode    0644
    owner   node[CPOD][:owner_name]
    group   node[CPOD][:owner_name]
end

template "#{BASE}/.gitconfig" do
    action  :create
    source  'gitconfig.erb'
    mode    0644
    owner   node[CPOD][:owner_name]
    group   node[CPOD][:owner_name]
    variables(
	:useremail => 'c-pod@sendium.net', :usergecos => 'C-Pod Repo User'
    )
end

directory "#{BASE}/.ssh" do
    owner node[CPOD][:owner_name]
    group node[CPOD][:owner_name]
    mode 0750
end

remote_file "#{BASE}/.ssh/authorized_keys" do
    action  :create_if_missing
    source "https://github.com/townsen.keys"
    mode    0644
    owner   node[CPOD][:owner_name]
    group   node[CPOD][:owner_name]
end

git "#{BASE}/c-pod" do
    repository "git@github.com:iParadigms/c-pod.git"
    reference "master"
    action :checkout # don't sync - do this manually
    group "apache"
    notifies :run, "execute[repo_permissions]", :immediate
    notifies :run, "execute[setup_repo]", :immediate
    notifies :restart, "service[httpd]", :delayed
end

# Git repos come out 644 and 755 so fix group permissions
execute "repo_permissions" do
    action :nothing
    command "chmod -R g+w #{BASE}/c-pod"
end

execute "setup_repo" do
    action :nothing
    command "#{BASE}/c-pod/bin/setup_repo"
end

directory "/#{BASE}/c-pod" do
    action :create
    mode 02770
    owner node[CPOD][:owner_name]
    group "apache"
    subscribes :create, "git[/#{BASE}/c-pod]", :immediate
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

# vim: sts=4 sw=4 ts=8
