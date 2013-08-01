# Kickstart file for a bare Centos 6 Virtual Machine with LVM
# Nick Townsend, April 2010
# Note that you must supply the hostname as a query parameter on kickstart:
#
# http://repo.myco.com/ks/centos6-vm.ks?host=machine02
#
<!--#include virtual="include/globals.ks" -->
<!--#include virtual="include/opts_vm.ks" -->
<!--#include virtual="include/dvdimage-centos6.ks" -->
network --device eth0 <!--#exec cgi="/bin/netcfg.cgi" --> --nameserver <!--#echo var="nameservers" -->
<!--#include virtual="include/rootpw_secret.ks" -->
<!--#include virtual="include/disk_lvm.ks" -->
<!--#include virtual="include/ksrepo-centos6.ks" -->
%packages
<!--#include virtual="include/pkgs_min-centos6.ks" -->
<!--#include virtual="include/pkgs_puppet-centos6.ks" -->
%post --interpreter /bin/bash
<!--#include virtual="include/strepo-centos6.ks" -->
<!--#include virtual="include/multilibs.ks" -->
<!--#include virtual="include/config_vm.ks" -->
<!--#include virtual="include/setuproot.ks" -->
<!--#include virtual="include/puppet-centos6.ks" -->
