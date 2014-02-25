# A Recipe to setup the Proxy server on a repo
#
yum_package 'dante-server >= 1.4.0'

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
