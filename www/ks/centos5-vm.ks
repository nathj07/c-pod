# Kickstart file for a bare Virtual Machine using LVM
# Nick Townsend, April 2010
# Note that you must supply the hostname as a query parameter on kickstart:
#
# http://repo.myco.com/ks/centos-vm.ks?host=machine01
#
<!--#include virtual="include/globals.ks" -->
<!--#include virtual="include/opts_vm.ks" -->
<!--#include virtual="include/dvdimage.ks" -->
network --device eth0 <!--#exec cgi="/bin/netcfg.cgi" --> --nameserver <!--#echo var="nameservers" -->
<!--#include virtual="include/rootpw_secret.ks" -->
<!--#include virtual="include/disk_lvm.ks" -->
<!--#include virtual="include/ksrepo.ks" -->
%packages
<!--#include virtual="include/pkgs_min.ks" -->
<!--#include virtual="include/pkgs_puppet.ks" -->
%post --interpreter /bin/bash
<!--#include virtual="include/strepo.ks" -->
<!--#include virtual="include/multilibs.ks" -->
<!--#include virtual="include/config_vm.ks" -->
<!--#include virtual="include/setuproot.ks" -->
<!--#include virtual="include/puppet.ks" -->
