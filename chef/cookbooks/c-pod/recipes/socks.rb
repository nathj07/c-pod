# A Recipe to setup the Proxy server on a repo
# Also adds the NATPMP facility
#
yum_package 'dante-server' do
    version '1.3.2-1.el6' # 1.4.0 as packaged by RPM forge was a little unreliable
    allow_downgrade true
end
yum_package 'stallone >= 0.4.0'

template "/etc/sockd.conf" do
    action  :create
    source  'sockd.conf.erb'
    mode    0644
    owner   'root'
    group   'root'
    variables( 
	:public => 'eth0',
	:private => 'virbr0'
    )
    notifies :restart, "service[sockd]", :delayed
end

cookbook_file "/etc/rc.d/rc.local" do
    action  :create
    mode    0755
    owner   'root'
    group   'root'
end

service 'sockd' do
    supports :restart => true, :reload => true
    action [:disable, :start]
end

# vim: sts=4 sw=4 ts=8
