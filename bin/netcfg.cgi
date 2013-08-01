#!/usr/bin/perl 
#
# Script to return the network parameters given a hostname
# TODO fix derivation of the default gateway from the IP address and netmask
#
use CGI;
use strict;
use warnings;

my $q = CGI->new;
my $hostname = $q->param('host');

$hostname = "centos.local" unless $hostname;

if (`host $hostname` =~ /\s+has\s+address\s+([0-9\.]+)$/) {
	my $fullhost = $`;
	my $ip = $1;
	my @ip = split /\./,$ip;
	$ip[3] = '1';
	my $gw = join('.',@ip);

	my $netmask = '255.255.255.0';

	print $q->header('text/plain', '200');
	print "--bootproto static --ip $ip --netmask $netmask --gateway $gw --hostname $fullhost";
}
else { # If can't find host then use DHCP 
	print $q->header('text/plain', '200');
	print "--bootproto dhcp --hostname $hostname";
}

