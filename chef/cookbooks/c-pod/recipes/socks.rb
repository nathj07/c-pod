# A Recipe to setup a SOCKS Proxy server
# This is called from the Docker recipe
# to allow communication with containers
#

ohai "getnetifs" do
  action :reload
  plugin "network"
end

sysctl 'net.ipv4.ip_forward' do
  value '1'
end

case node[:platform_family]
when 'rhel'

    yum_package 'dante-server'

    template "/etc/sockd.conf" do
	action  :create
	source  'sockd.conf.erb'
	mode    0644
	owner   'root'
	group   'root'
	variables(
            public_if:  node[:cpod][:socks][:public_if],
            private_if: node[:cpod][:socks][:private_if]
	)
	notifies :restart, "service[sockd]", :delayed
    end

      case osver
      when 5...7
        cookbook_file "/etc/rc.d/rc.local" do
            action  :create
            mode    0755
            owner   'root'
            group   'root'
        end
      when 7...8
        cookbook_file "/lib/systemd/system/sockd.service" do
            source  'danted.service'
            action  :create
            mode    0755
            owner   'root'
            group   'root'
        end
      end

    service 'sockd' do
	supports :restart => true, :reload => true
	action [:enable, :start]
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
            public_if:  node[:cpod][:socks][:public_if],
            private_if: (node[:cpod][:socks][:private_if] or node[:cpod][:docker][:interface])
	)
	notifies :restart, "service[danted]", :delayed
    end

    service 'danted' do
	supports :restart => true, :reload => true
	action [:disable, :start]
    end

when 'mac_os_x'
    error "This is never likely to be supported!"

end

# vim: sts=4 sw=4 ts=8
