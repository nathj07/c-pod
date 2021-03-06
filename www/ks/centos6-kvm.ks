# Kickstart file for a bare CentOS 6 Virtual Machine with LVM
# Note that you must supply the hostname as a query parameter on kickstart:
#
# http://repo.myco.com/ks/centos6-kvm.ks?host=machine02.local
#
<!--#include virtual="include/opts_vm-centos6.ks" -->
<!--#include virtual="include/dvdimage-centos6.ks" -->
network --device eth0 <!--#exec cgi="/bin/netcfg.centos.cgi" -->

<!--#include virtual="include/rootpw_secret.ks" -->
# Fix bug where clearpart prompts on new disk
zerombr

<!--#include virtual="include/disk_kvm_lvm.ks" -->
<!--#include virtual="include/lifted6_repo.ks" -->
%packages
<!--#include virtual="include/pkgs_min-centos6.ks" -->
%post --interpreter /bin/bash
<!--#include virtual="include/yum-repo.ks" -->
<!--#include virtual="include/advertize.ks" -->
<!--#include virtual="include/setuproot.ks" -->
<!--#include virtual="include/rubygems.ks" -->
<!--#include virtual="include/chef.ks" -->
