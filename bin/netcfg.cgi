#!/usr/bin/perl 
#
# Script to return the network parameters given a hostname
#
# --ip 10.10.30.101 --netmask 255.255.255.0 --gateway 10.10.30.1 --nameserver 10.10.30.70 --hostname bp01.blurb.com
#
use CGI;
use strict;
use warnings;

my $q = CGI->new;
my $hostname = $q->param('host');

$hostname .= ".blurb.com" unless $hostname =~ /\.blurb\.com$/;

# If can't find host then use DHCP 
if (`host $hostname` =~ /has\s+address\s+([0-9\.]+)$/) {
	my $ip = $1;
	my @ip = split /\./,$ip;
	$ip[3] = '1';
	my $gw = join('.',@ip);

	my $netmask = '255.255.255.0';

	print $q->header('text/plain', '200');
	print "--bootproto static --ip $ip --netmask $netmask --gateway $gw --hostname $hostname";
}
else {
	print $q->header('text/plain', '200');
	print "--bootproto dhcp";
}

