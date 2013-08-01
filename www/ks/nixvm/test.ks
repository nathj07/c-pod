# Kickstart file for a fixed IP puppet configured test RedHat Virtual Machine
# Nick Townsend, Sept 2010
#
<!--#include virtual="/ks/include/opts_vm.ks" -->

<!--#include virtual="/ks/include/dvdimage.ks" -->

network --device eth0 --bootproto static --ip 192.168.2.225 --netmask 255.255.254.0 --gateway 192.168.2.1 --nameserver 10.10.30.70 --hostname nixvm-test.myco.com
# network --device eth0 --bootproto dhcp --hostname nixvm-test.local

<!--#include virtual="/ks/include/rootpw_secret.ks" -->

<!--#include virtual="/ks/include/disk_lvm_small.ks" -->

<!--#include virtual="/ks/include/ksrepo.ks" -->

%packages

<!--#include virtual="/ks/include/pkgs_min.ks" -->
<!--#include virtual="/ks/include/pkgs_puppet.ks" -->

%post --interpreter /bin/bash
<!--#include virtual="/ks/include/strepo_centos6.ks" -->
<!--#include virtual="/ks/include/multilibs.ks" -->
<!--#include virtual="/ks/include/config_vm.ks" -->
<!--#include virtual="/ks/include/puppet.ks" -->
<!--#include virtual="setupnick.ks" -->
