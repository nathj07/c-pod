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

# vim: sts=4 sw=4 ts=8
