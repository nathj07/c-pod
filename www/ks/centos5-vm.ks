# Kickstart file for a bare CentOS 5 Virtual Machine using LVM
# Note that you must supply the hostname as a query parameter on kickstart:
#
# http://repo.myco.com/ks/centos5-vm.ks?host=machine01
#
<!--#include virtual="include/opts_vm-centos5.ks" -->
<!--#include virtual="include/dvdimage-centos5.ks" -->
network --device eth0 <!--#exec cgi="/bin/netcfg.centos.cgi" -->

<!--#include virtual="include/rootpw_secret.ks" -->
<!--#include virtual="include/disk_lvm_single.ks" -->
<!--#include virtual="include/lifted5_repo.ks" -->
%packages

<!--#include virtual="include/pkgs_min-centos5.ks" -->
%post --interpreter /bin/bash

<!--#include virtual="include/yum-repo.ks" -->
<!--#include virtual="include/advertize.ks" -->
<!--#include virtual="include/vmware_tools.ks" -->
<!--#include virtual="include/setuproot.ks" -->
<!--#include virtual="include/rubygems.ks" -->
<!--#include virtual="include/chef.ks" -->
<!--#include virtual="include/chefpath.ks" -->
