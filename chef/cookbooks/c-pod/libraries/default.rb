# Library of utility functions for chef
#
def validate_platform
    raise "Can only use this recipe on CentOS, not #{node[:platform]}" \
	unless platform_family? 'rhel'
    raise "Can't parse platform version #{node[:platform_version]}" \
	unless /(?<maj>\d+)\.(?<min>\d+)$/ =~ node[:platform_version]
    raise "Can't handle #{node[:platform]} #{version}" unless [5,6].include? maj.to_i
    return node[:platform_version].to_r
end

def osver
    return node[:platform_version].to_r
end

# The same as the rpm dist macro so we can check exact packages
# Needed as package version comparison in chef won't partial match
# on the packaging piece: 1.0-13ip won't match log4cpp-1.0-13ip.el5
# so recipes must have fully qualified names. Smells bad.
#
def dist
    raise "Invalid distro #{node[:platform]}" unless platform_family? 'rhel'
    return ".el#{node[:platform_version][0]}"
end

# like the built_in value_for_platform but allows selector to be number, regex, range
#
def value_for_version hash
    key = hash.keys.select do |k|
	k = k.to_s if k.is_a?(Numeric)
	v = k.is_a?(Range) ? node[:platform_version].to_r : node[:platform_version]
	k === v
    end.first
    raise "No key matches #{node[:platform_version]}" unless key
    hash[key]
end

# Translate an interface into a CIDR address
#
def cidr interface
    node[:network][:interfaces][interface.to_sym][:routes].detect {|r| r[:family] == "inet"}[:destination]
end

# vim: sts=4 sw=4 ts=8
