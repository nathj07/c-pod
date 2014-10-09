# A Recipe to setup the Proxy server on a repo
# Also adds the NATPMP facility
#
case node[:platform_family]
when 'rhel'

    yum_package 'dante-server >= 1.4.0' do
	action  :upgrade
	allow_downgrade true
    end

    case osver 
    when 6...7 then yum_package 'stallone >= 0.4.0'
    else warn "Don't have a package of stallone for Centos7 yet"
    end

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

when 'debian'
    package 'dante-server'

    template "/etc/danted.conf" do
	action  :create
	source  'sockd.conf.erb'
	mode    0644
	owner   'root'
	group   'root'
	variables( 
	    :public => 'eth0',
	    :private => 'virbr0'
	)
	notifies :restart, "service[danted]", :delayed
    end

    service 'danted' do
	supports :restart => true, :reload => true
	action [:disable, :start]
    end

when 'mac_os_x'
    error "This will never likely to be supported!"

end

# vim: sts=4 sw=4 ts=8
