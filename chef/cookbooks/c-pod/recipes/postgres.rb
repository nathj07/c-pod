# A Recipe to setup PostgreSQL
#
node.default[:postgres][:version] = "9.2"
node.default[:postgres][:datadir] = '/var/lib/pgsql/9.2/data'
node.default[:postgres][:bindir] = '/usr/pgsql-9.2/bin'
node.default[:postgres][:user] = 'postgres'
node.default[:postgres][:group] = 'postgres'

directory node[:postgres][:datadir] do
    recursive true
    owner   node[:postgres][:user]
    group   node[:postgres][:group]
    mode    0700
end

yum_package 'postgresql92-server' do
    notifies :run, "execute[initdb]", :immediate
end

template "#{node[:postgres][:datadir]}/pg_hba.conf" do
    owner   node[:postgres][:user]
    group   node[:postgres][:group]
    mode    0600
    notifies :restart, "service[postgresql-9.2]", :delayed
end

cookbook_file "/var/lib/pgsql/.bash_profile" do
    source  'pguser.bash_profile'
    owner   node[:postgres][:user]
    group   node[:postgres][:group]
    mode    0644
end

execute "initdb" do
    action :nothing
    command "service postgresql-9.2 initdb"
    user    'root'
    notifies :start, "service[postgresql-9.2]", :immediate
end

service 'postgresql-9.2' do
    supports :restart => true, :reload => true
    action :enable
end

# vim: sts=4 sw=4 ts=8
