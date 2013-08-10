# Demo of chef solo: preparing a repo machine
# (incomplete)
#
yum_package 'httpd'
gem_package 'redcarpet' do # for markdown
    options "--no-rdoc --no-ri"
end
gem_package 'builder'   # for gem building

directory '/data' do
    user "apache"
    group "apache"
end

git "/data/repo" do
    repository "https://github.com/townsen/repo.git"
    reference "master"
    action :sync
    user "apache"
    group "apache"
    notifies :run, "execute[setup_repo]", :immediate
    notifies :restart, "service[httpd]", :delayed
end

execute "setup_repo" do
    action :nothing
    command "/data/repo/bin/setup_repo"
    creates "/etc/httpd/conf.d/_repo.conf"
end

service 'httpd' do
    supports :restart => true, :reload => true
    action :nothing
end

# vim: sts=4 sw=4 ts=8
