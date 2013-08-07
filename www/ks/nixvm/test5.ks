# Kickstart file for a local CentOS 5 test machine
#
<!--#include virtual="/ks/include/opts_vm-centos5.ks" -->
<!--#include virtual="/ks/include/dvdimage-centos5.ks" -->
network --device eth0 <!--#exec cgi="/bin/netcfg.cgi" -->
<!--#include virtual="/ks/include/rootpw_secret.ks" -->
<!--#include virtual="/ks/include/disk_lvm_single.ks" -->
<!--#include virtual="/ks/include/ksrepo-centos5.ks" -->
<!--#include virtual="/ks/include/epel5.ks" -->
%packages
<!--#include virtual="/ks/include/pkgs_min-centos5.ks" -->
<!--#include virtual="/ks/include/pkgs_ruby.ks" -->
%post --interpreter /bin/bash
<!--#include virtual="/ks/include/custom_repo.ks" -->
<!--#include virtual="/ks/include/multilibs.ks" -->
<!--#include virtual="/ks/include/config_vm.ks" -->
<!--#include virtual="setupnick.ks" -->
