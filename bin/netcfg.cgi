#!/usr/bin/env ruby
#
# Script to return the network parameters given a hostname
# Note that determination of the netmask from the IP must
# be customized in the file netmask_table in this dir
#
# This script is invoked by SSI exec cgi from within other
# Kickstart and Preseed files. SSI exec cgi must be used as it
# preserves the original request parameters containing the
# hostname in contrast to the recommended SSI include virtual
# which does not.
# However SSI exec cgi does not allow specification of additional
# path info or query parameters, so in order to differentiate
# between OS's we use the script name and link this same script
# with different names for each OS family.
#
require 'cgi'
require 'resolv'
require 'ipaddr'

masks = File.open(File.expand_path('../netmask_table', __FILE__), &:read).split(/\n/).grep(/^(?!\s*#)/) rescue []
# Add the RFC1918 ones as fallback
masks << '^10\.	        255.0.0.0'
masks << '^172\.16\.	255.240.0.0'
masks << '^192\.168\.	255.255.255.0'
masks.map! {|m| am = m.split; [Regexp.new(am[0]), am[1]] }

q = CGI.new
opts = {}
q.out 'text/plain' do

    opts[:hostname] = q.has_key?('host') ? q['host']: 'vm.local'

    host, domain = opts[:hostname].split('.',2)

    if domain.end_with? 'local'
	opts[:bootproto] = 'dhcp'
    else
	Resolv::DNS.open do |dns|
	    dns.timeouts = 5 if RUBY_VERSION =~ /^2/
	    addr = dns.getaddress(opts[:hostname]).to_s rescue nil
	    if addr
		opts[:bootproto] = 'static'
		ipaddr = IPAddr.new addr
		netmask = masks.find(['*','255.255.255.0']){|m| m[0].match addr }[1]
		gw = ipaddr.mask(netmask).succ
                opts[:addr] = addr
                opts[:netmask] = netmask
                opts[:gw] = gw.to_s
                opts[:nameservers] = dns.instance_variable_get(:@config).nameserver_port.map(&:first)
	    else
		opts[:bootproto] = 'dhcp'
	    end
	end
    end
    os = q.script_name.split('.',3)[1] # netcfg.<OS family>.cgi
    case os
    when 'ubuntu'
        <<-DEB.gsub(/^\s+/,'')
            d-i netcfg/get_domain string #{domain}
            d-i netcfg/get_hostname string #{host}
            d-i netcfg/hostname string #{host}
            d-i netcfg/dhcp_hostname string #{host}
        DEB
    when 'centos'
        args = ["--hostname #{opts[:hostname]}"]
	args.push "--bootproto #{opts[:bootproto]}"
        if opts[:bootproto] == 'static'
            args.push "--ip #{opts[:addr]} --netmask #{opts[:netmask]} --gateway #{opts[:gw]}"
            args.push "--nameserver #{opts[:nameservers].join(',')}" if opts[:nameservers]
        end
        args.join(' ')
    else
        "Unknown OS: #{os}"
    end

end

# vim: sts=4 sw=4 ts=8
