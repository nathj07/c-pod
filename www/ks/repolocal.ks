# Kickstart file for a local copy of the repo machine
#
<!--#include virtual="/ks/include/opts_vm-centos6.ks" -->
<!--#include virtual="/ks/include/dvdimage-centos6.ks" -->
cdrom
network --device eth0 --bootproto dhcp --hostname repo.local
<!--#include virtual="/ks/include/rootpw_secret.ks" -->
<!--#include virtual="/ks/include/disk_lvm_single.ks" -->
<!--#include virtual="/ks/include/ksrepo-centos6.ks" -->
%packages
<!--#include virtual="/ks/include/pkgs_min-centos6.ks" -->
<!--#include virtual="/ks/include/pkgs_repo.ks" -->
<!--#include virtual="/ks/include/pkgs_ruby.ks" -->

%post --interpreter /bin/bash
<!--#include virtual="/ks/include/multilibs.ks" -->
<!--#include virtual="/ks/include/config_vm.ks" -->
<!--#include virtual="setuproot.ks" -->
<!--#include virtual="setupnick.ks" -->
