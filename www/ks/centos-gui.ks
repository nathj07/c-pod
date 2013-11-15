# Kickstart file for a Gnome Desktop Virtual Machine
# Nick Townsend, April 2010
#

<!--#include virtual="include/opts_vm-centos6.ks" -->

xconfig --defaultdesktop=GNOME --resolution=1024x768 --startxonboot --depth=24

<!--#include virtual="include/dvdimage-centos6.ks" -->

network --device eth0 --bootproto dhcp --hostname centos-vm.local

<!--#include virtual="include/rootpw_secret.ks" -->

# Fix bug where clearpart prompts on new disk
zerombr
<!--#include virtual="include/disk_lvm_single.ks" -->

<!--#include virtual="include/lifted6_repo.ks" -->

%packages
<!--#include virtual="include/pkgs_min-centos6.ks" -->
<!--#include virtual="include/pkgs_mindev.ks" -->
@base-x
@gnome-desktop

%post --interpreter /bin/bash
<!--#include virtual="include/multilibs.ks" -->
<!--#include virtual="include/vmware_tools.ks" -->
