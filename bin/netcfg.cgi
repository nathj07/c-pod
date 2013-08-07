#!/usr/bin/env ruby
#
# Script to return the network parameters given a hostname
# TODO fix derivation of the default gateway from the IP address and netmask
#
require 'cgi'

q = CGI.new
hostname = q.has_key?('host') ? q['host'] : "centos.local"

q.out 'text/plain' do
    if /\s+has\s+address\s+(?<ip>[0-9\.]+)$/ =~ `host #{hostname}`
	fullhost = $`
	aip = ip.split '.'
	aip[3] = '1'
	gw = aip.join '.'
	netmask = '255.255.255.0'
	"--bootproto static --ip #{ip} --netmask #{netmask} --gateway #{gw} --hostname #{fullhost}"
    else # If can't find host then use DHCP
	"--bootproto dhcp --hostname #{hostname}"
    end
end

# vim: sts=4 sw=4 ts=8
