# Kickstart file for a bare test  RedHat Virtual Machine
# Nick Townsend, April 2010
#
<!--#include virtual="/ks/include/opts_vm.ks" -->

<!--#include virtual="/ks/include/dvdimage-centos6.ks" -->

network --device eth0 --bootproto dhcp --hostname nixvm-test.local

<!--#include virtual="/ks/include/rootpw_secret.ks" -->

<!--#include virtual="/ks/include/disk_single.ks" --

<!--#include virtual="/ks/include/ksrepo.ks" -->

%packages

<!--#include virtual="/ks/include/pkgs_min.ks" -->

%post --interpreter /bin/bash
<!--#include virtual="/ks/include/strepo.ks" -->
<!--#include virtual="/ks/include/multilibs.ks" -->
<!--#include virtual="/ks/include/config_vm.ks" -->
<!--#include virtual="setupnick.ks" -->
