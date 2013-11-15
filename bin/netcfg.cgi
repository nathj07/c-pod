#!/usr/bin/env ruby
#
# Script to return the network parameters given a hostname
# TODO derivation of the netmask and gateway is inherently flaky
#
require 'cgi'
require 'resolv'
require 'ipaddr'

q = CGI.new

q.out 'text/plain' do

    hostname = q.has_key?('host') ? q['host']: 'centos.local'
    opts = ["--hostname #{hostname}"]

    if hostname.end_with? '.local'
	opts.unshift "--bootproto dhcp"
    else
	Resolv::DNS.open do |dns|
	    dns.timeouts = 5
	    addr = dns.getaddress(hostname).to_s rescue nil
	    if addr
		opts.unshift "--bootproto static"
		ipaddr = IPAddr.new addr
		netmask = case addr
		    when /^10\./	then '255.0.0.0'
		    when /^172\.16\./	then '255.240.0.0'
		    when /^192\.168\./	then '255.255.255.0'
		    else '255.255.255.0'
		end
		gw = ipaddr.mask(netmask).succ
		opts.push "--ip #{addr} --netmask #{netmask} --gateway #{gw.to_s}"
		opts.push "--nameservers #{ENV['nameservers']}" if ENV.include? 'nameservers'
	    else
		opts.unshift "--bootproto dhcp"
	    end
	end
    end
    opts.join(' ')
end

# vim: sts=4 sw=4 ts=8
