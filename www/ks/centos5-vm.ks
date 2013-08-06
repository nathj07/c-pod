# Kickstart file for a bare CentOS 5 Virtual Machine using LVM
# Note that you must supply the hostname as a query parameter on kickstart:
#
# http://repo.myco.com/ks/centos5-vm.ks?host=machine01
#
<!--#include virtual="include/globals.ks" -->
<!--#include virtual="include/opts_vm-centos5.ks" -->
<!--#include virtual="include/dvdimage-centos5.ks" -->
network --device eth0 <!--#exec cgi="/bin/netcfg.cgi" --> --nameserver <!--#echo var="nameservers" -->
<!--#include virtual="include/rootpw_secret.ks" -->
<!--#include virtual="include/disk_lvm_single.ks" -->
<!--#include virtual="include/epel5.ks" -->
<!--#include virtual="include/ksrepo-centos5.ks" -->
%packages
<!--#include virtual="include/pkgs_min-centos5.ks" -->
<!--#include virtual="include/pkgs_ruby.ks" -->
%post --interpreter /bin/bash
<!--#include virtual="include/custom_repo.ks" -->
<!--#include virtual="include/multilibs.ks" -->
<!--#include virtual="include/config_vm.ks" -->
<!--#include virtual="include/setuproot.ks" -->
