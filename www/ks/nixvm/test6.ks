# Kickstart file for a local CentOS 6 test machine
# Nick Townsend, July 2011
#
<!--#include virtual="/ks/include/opts_vm-centos6.ks" -->
<!--#include virtual="/ks/include/dvdimage-centos6.ks" -->
network --device eth0 <!--#exec cgi="/bin/netcfg.cgi" -->
<!--#include virtual="/ks/include/rootpw_secret.ks" -->
<!--#include virtual="/ks/include/disk_lvm_single.ks" -->
<!--#include virtual="/ks/include/ksrepo-centos6.ks" -->
<!--#include virtual="/ks/include/epel6.ks" -->
%packages
<!--#include virtual="/ks/include/pkgs_min-centos6.ks" -->
<!--#include virtual="/ks/include/pkgs_ruby.ks" -->
<!--#include virtual="/ks/include/pkgs_build.ks" -->
%post --interpreter /bin/bash
<!--#include virtual="/ks/include/custom_repo.ks" -->
<!--#include virtual="/ks/include/multilibs.ks" -->
<!--#include virtual="/ks/include/config_vm.ks" -->
<!--#include virtual="setupnick.ks" -->
