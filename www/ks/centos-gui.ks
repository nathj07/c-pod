# Kickstart file for a Gnome Desktop Virtual Machine
# Nick Townsend, April 2010
#

<!--#include virtual="include/opts_vm-centos6.ks" -->

xconfig --defaultdesktop=GNOME --resolution=1024x768 --startxonboot --depth=24

<!--#include virtual="include/dvdimage-centos6.ks" -->

network --device eth0 --bootproto dhcp --hostname centos-vm.local

<!--#include virtual="include/rootpw_secret.ks" -->

<!--#include virtual="include/disk_lvm_single.ks" -->

<!--#include virtual="include/ksrepo-centos6.ks" -->

%packages
<!--#include virtual="include/pkgs_min-centos6.ks" -->
@base-x
@gnome-desktop

%post --interpreter /bin/bash
<!--#include virtual="include/custom_repo.ks" -->
<!--#include virtual="include/multilibs.ks" -->
<!--#include virtual="include/vmware_tools.ks" -->
