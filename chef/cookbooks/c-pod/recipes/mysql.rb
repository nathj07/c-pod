# A Recipe to setup MySQL
#
node.default[:mysql][:version] = "5.1"
node.default[:mysql][:datadir] = '/var/lib/mysql'
node.default[:mysql][:bindir] = '/usr/bin/mysql'
node.default[:mysql][:initd] = '/etc/init.d/mysqld'
node.default[:mysql][:confdir] = '/etc'
node.default[:mysql][:socket] = '/var/lib/mysql/mysql.sock'
node.default[:mysql][:user] = 'mysql'
node.default[:mysql][:group] = 'mysql'

directory node[:mysql][:datadir] do
    recursive true
    owner   node[:mysql][:user]
    group   node[:mysql][:group]
    mode    0700
end

yum_package 'mysql-server' do
    notifies :run, "execute[initdb]", :immediate
end

template "#{node[:mysql][:confidir]}/my.cnf" do
    owner   node[:mysql][:user]
    group   node[:mysql][:group]
    mode    0600
    notifies :restart, "service[mysqld]", :delayed
end

execute "initdb" do
    action :nothing
    command "#{node[:mysql][:initd]} start"
    user    'root'
    notifies :start, "service[mysqld]", :immediate
end

service 'mysqld' do
    supports :restart => true, :reload => true
    action :enable
end

# vim: sts=4 sw=4 ts=8