# Default Node Attributes for a C-Pod
#
default[:cpod][:server_name] = node[:fqdn]
default[:cpod][:base] = case node[:platform_family] 
			     when 'rhel' then '/data' 
			     when 'debian' then '/srv'
			     else error "Not supported"
			     end
default[:cpod][:datadir] = File.join(node[:cpod][:base],'repo')
default[:cpod][:owner_name] = 'c-pod'
