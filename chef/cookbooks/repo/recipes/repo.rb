# Preparing a repo machine
# Note use of setgid and apache group to allow sharing
# Together with umask 0002
#
yum_package 'httpd'
yum_package 'createrepo'
gem_package 'redcarpet' do # for markdown
    options "--no-rdoc --no-ri"
end
gem_package 'builder'   # for gem building

repo_owner_name = 'packager'
repo_owner_id = 626

group repo_owner_name do
  action :create
  gid repo_owner_id
end

user repo_owner_name do
  action :create
  comment "Repo user"
  home '/data'
  gid repo_owner_id
  uid repo_owner_id
  supports :manage_home => false
end

directory '/data' do
    user repo_owner_name
    group repo_owner_name
    mode 02755		# need setgid so that all are apache group
end

cookbook_file "/data/README" do
    source  'README.data'
    mode    0644
    owner   repo_owner_name
    group   repo_owner_name
end

template "/data/.gitconfig" do
    action  :create
    source  'gitconfig.erb'
    mode    0644
    owner   repo_owner_name
    group   repo_owner_name
    variables(
	:useremail => 'nick.townsend@mac.com', :usergecos => 'Nick Townsend'
    )
end

git "/data/repo" do
    repository "git@github.com:townsen/repo.git"
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
    command "chmod -R g+w /data/repo"
end

execute "setup_repo" do
    action :nothing
    command "/data/repo/bin/setup_repo"
end

directory '/data/repo' do
    action :create
    mode 02770
    user repo_owner_name
    group "apache"
    subscribes :create, "git[/data/repo]", :immediate
end

service 'httpd' do
    supports :restart => true, :reload => true
    action :enable
end

# vim: sts=4 sw=4 ts=8
