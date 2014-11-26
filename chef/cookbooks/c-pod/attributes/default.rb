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
default[:cpod][:owner_id]   = 606
default[:cpod][:github_key] = 'townsen' # User to give public key access
default[:cpod][:admin_email] = 'nick.townsend@mac.com'
