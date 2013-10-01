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

directory '/data' do
    user "apache"
    group "apache"
    mode 02770		# need setgid so that all are apache group
end

git "/data/repo" do
    repository "git@github.com:townsen/repo.git"
    reference "master"
    action :sync
#    user "apache"
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
    creates "/etc/httpd/conf.d/_repo.conf"
end

directory '/data/repo' do
    action :create
    mode 02770
    user "apache"
    group "apache"
    subscribes :create, "git[/data/repo]", :immediate
end

service 'httpd' do
    supports :restart => true, :reload => true
    action :enable
end

# vim: sts=4 sw=4 ts=8
