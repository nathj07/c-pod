# Demo of chef solo: preparing a repo machine
# (incomplete)
#
yum_package 'httpd' do
    version "2.2.15-26.el6.centos"
end

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
end

service 'httpd' do
  action :restart
end

# vim: sts=4 sw=4 ts=8
