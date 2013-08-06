# Kickstart file for a bare CentOS 6 Virtual Machine with LVM
# Note that you must supply the hostname as a query parameter on kickstart:
#
# http://repo.myco.com/ks/centos6-vm.ks?host=machine02
#
<!--#include virtual="include/globals.ks" -->
<!--#include virtual="include/opts_vm-centos6.ks" -->
<!--#include virtual="include/dvdimage-centos6.ks" -->
network --device eth0 <!--#exec cgi="/bin/netcfg.cgi" --> --nameserver <!--#echo var="nameservers" -->
<!--#include virtual="include/rootpw_secret.ks" -->
<!--#include virtual="include/disk_lvm_single.ks" -->
<!--#include virtual="include/ksrepo-centos6.ks" -->
<!--#include virtual="include/epel6.ks" -->
%packages
<!--#include virtual="include/pkgs_min-centos6.ks" -->
<!--#include virtual="include/pkgs_ruby.ks" -->
%post --interpreter /bin/bash
<!--#include virtual="include/custom_repo.ks" -->
<!--#include virtual="include/multilibs.ks" -->
<!--#include virtual="include/config_vm.ks" -->
<!--#include virtual="include/setuproot.ks" -->
