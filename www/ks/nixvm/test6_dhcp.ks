# Kickstart file for a fixed IP puppet configured test RedHat Virtual Machine
# Updated for Red Hat 6.1
# Nick Townsend, July 2011
#
<!--#include virtual="/ks/include/opts_vm.ks" -->

<!--#include virtual="/ks/include/dvdimage-centos6.ks" -->

network --device eth0 --bootproto dhcp --hostname nixvm-test.local

<!--#include virtual="/ks/include/rootpw_secret.ks" -->

<!--#include virtual="/ks/include/disk_lvm_single.ks" -->

<!--#include virtual="/ks/include/ksrepo-centos6.ks" -->

%packages

<!--#include virtual="/ks/include/pkgs_min-centos6.ks" -->
<!--#include virtual="/ks/include/pkgs_puppet-centos6.ks" -->

%post --interpreter /bin/bash
<!--#include virtual="/ks/include/strepo-centos6.ks" -->
<!--#include virtual="/ks/include/multilibs.ks" -->
<!--#include virtual="/ks/include/config_vm.ks" -->
<!--#include virtual="/ks/include/puppet-centos6.ks" -->
<!--#include virtual="setupnick.ks" -->
